#include <jni.h>
#include <string>

extern "C" {
#include "include/libavcodec/avcodec.h"
#include "include/libavformat/avformat.h"
#include "include/libavfilter/avfilter.h"
#include "include/libavutil/avutil.h"
#include "libavutil/timestamp.h"
#include "libavutil/mathematics.h"
#include "android_log.h"
}

extern "C"
JNIEXPORT int JNICALL
Java_com_jeffmony_ffmpeglib_FFmpegRemuxUtils_remux(JNIEnv *env, jclass clazz, jstring input_path,
                                                   jstring output_path) {
    if(use_log_report)
    {
        av_log_set_callback(ffp_log_callback_report);
    }
    else
    {
        av_log_set_callback(ffp_log_callback_brief);
    }
    const char *in_filename = env->GetStringUTFChars(input_path, 0);
    const char *out_filename = env->GetStringUTFChars(output_path, 0);
    LOGI("Input_path=%s, Output_path=%s", in_filename, out_filename);
    AVOutputFormat *ofmt = NULL;
    AVFormatContext *ifmt_ctx = NULL, *ofmt_ctx = NULL;
    AVPacket pkt;
    int ret, i;
    int stream_index = 0;
    int *stream_mapping = NULL;
    int stream_mapping_size = 0;

    if ((ret = avformat_open_input(&ifmt_ctx, in_filename, 0, 0)) < 0) {
        LOGE("Could not open input file '%s'", in_filename);
        goto end;
    }

    if ((ret = avformat_find_stream_info(ifmt_ctx, 0)) < 0) {
        LOGE("Failed to retrieve input stream information");
        goto end;
    }

    LOGI("Index=%d, duration=%lld",ifmt_ctx->nb_streams, ifmt_ctx->duration);

    av_dump_format(ifmt_ctx, 1, in_filename, 0);

    avformat_alloc_output_context2(&ofmt_ctx, NULL, NULL, out_filename);
    if (!ofmt_ctx) {
        LOGE("Could not create output context\n");
        ret = AVERROR_UNKNOWN;
        goto end;
    }
    LOGI("Output format=%s", ofmt_ctx->oformat->name);

    stream_mapping_size = ifmt_ctx->nb_streams;
    stream_mapping = (int *)av_mallocz_array(stream_mapping_size, sizeof(*stream_mapping));
    if (!stream_mapping) {
        ret = AVERROR(ENOMEM);
        goto end;
    }

    ofmt = ofmt_ctx->oformat;

    for (i = 0; i < ifmt_ctx->nb_streams; i++) {
        AVStream *out_stream;
        AVStream *in_stream = ifmt_ctx->streams[i];
        AVCodecParameters *in_codecpar = in_stream->codecpar;

        LOGI("width=%d, heigth=%d", in_codecpar->width, in_codecpar->height);

        if (in_codecpar->codec_type != AVMEDIA_TYPE_AUDIO &&
            in_codecpar->codec_type != AVMEDIA_TYPE_VIDEO &&
            in_codecpar->codec_type != AVMEDIA_TYPE_SUBTITLE) {
            stream_mapping[i] = -1;
            continue;
        }

        stream_mapping[i] = stream_index++;

        out_stream = avformat_new_stream(ofmt_ctx, NULL);
        if (!out_stream) {
            LOGE("Failed allocating output stream\n");
            ret = AVERROR_UNKNOWN;
            goto end;
        }

        ret = avcodec_parameters_copy(out_stream->codecpar, in_codecpar);
        if (ret < 0) {
            LOGE("Failed to copy codec parameters\n");
            goto end;
        }
        out_stream->codecpar->codec_tag = 0;
        if (in_codecpar->codec_type == AVMEDIA_TYPE_VIDEO) {
            out_stream->codecpar->codec_type == AVMEDIA_TYPE_VIDEO;
            out_stream->codecpar->width = 1280;
            out_stream->codecpar->height = 720;
        }
    }
    av_dump_format(ofmt_ctx, 0, out_filename, 1);

    if (!(ofmt->flags & AVFMT_NOFILE)) {
        LOGI("Open output file");
        ret = avio_open(&ofmt_ctx->pb, out_filename, AVIO_FLAG_WRITE);
        if (ret < 0) {
            LOGE("Could not open output file '%s'", out_filename);
            goto end;
        }
    }

    ret = avformat_write_header(ofmt_ctx, NULL);
    if (ret < 0) {
        LOGE("Error occurred when opening output file, ret=%d\n", ret);
        goto end;
    }

    while (1) {
        AVStream *in_stream, *out_stream;

        ret = av_read_frame(ifmt_ctx, &pkt);
        if (ret < 0)
            break;

        in_stream  = ifmt_ctx->streams[pkt.stream_index];
        if (pkt.stream_index >= stream_mapping_size ||
            stream_mapping[pkt.stream_index] < 0) {
            av_packet_unref(&pkt);
            continue;
        }

        pkt.stream_index = stream_mapping[pkt.stream_index];
        out_stream = ofmt_ctx->streams[pkt.stream_index];

        /* copy packet */
        pkt.pts = av_rescale_q_rnd(pkt.pts, in_stream->time_base, out_stream->time_base,
                                   static_cast<AVRounding>(AV_ROUND_NEAR_INF |
                                                           AV_ROUND_PASS_MINMAX));
        pkt.dts = av_rescale_q_rnd(pkt.dts, in_stream->time_base, out_stream->time_base,
                                   static_cast<AVRounding>(AV_ROUND_NEAR_INF |
                                                           AV_ROUND_PASS_MINMAX));
        pkt.duration = av_rescale_q(pkt.duration, in_stream->time_base, out_stream->time_base);
        pkt.pos = -1;

        ret = av_interleaved_write_frame(ofmt_ctx, &pkt);
        if (ret < 0) {
            LOGE("Error muxing packet\n");
            break;
        }
        av_packet_unref(&pkt);
    }

    av_write_trailer(ofmt_ctx);

    end:

    avformat_close_input(&ifmt_ctx);

    /* close output */
    if (ofmt_ctx && !(ofmt->flags & AVFMT_NOFILE))
        avio_closep(&ofmt_ctx->pb);
    avformat_free_context(ofmt_ctx);

    av_freep(&stream_mapping);

    if (ret < 0 && ret != AVERROR_EOF) {
        LOGE("Error occurred: %s\n", av_err2str(ret));
        return 1;
    }

    return 0;
}

extern "C"
JNIEXPORT jstring JNICALL
Java_com_jeffmony_ffmpeglib_FFmpegInfoUtils_stringFromJNI(JNIEnv *env, jclass clazz) {
    std::string hello = "Hello from C++";
    return env->NewStringUTF(hello.c_str());
}

extern "C"
JNIEXPORT jstring JNICALL
Java_com_jeffmony_ffmpeglib_FFmpegInfoUtils_avcodecInfo(JNIEnv *env, jclass clazz) {
    char info[40000] = {0};

    av_register_all();

    AVCodec *temp = av_codec_next(NULL);

    while (temp != NULL) {
        if (temp->decode != NULL) {
            sprintf(info, "%sdecode:", info);
        } else {
            sprintf(info, "%sencode:", info);
        }
        switch (temp->type) {
            case AVMEDIA_TYPE_VIDEO:
                sprintf(info, "%s(video):", info);
                break;
            case AVMEDIA_TYPE_AUDIO:
                sprintf(info, "%s(audio):", info);
                break;
            default:
                sprintf(info, "%s(other):", info);
                break;
        }
        sprintf(info, "%s[%10s]\n", info, temp->name);
        temp = temp->next;
    }

    return env->NewStringUTF(info);
}

extern "C"
JNIEXPORT jstring JNICALL
Java_com_jeffmony_ffmpeglib_FFmpegInfoUtils_avfilterInfo(JNIEnv *env, jclass clazz) {
    char info[40000] = {0};
    avfilter_register_all();

    AVFilter *temp = (AVFilter *)avfilter_next(NULL);
    while(temp != NULL) {
        sprintf(info, "%s%s\n", info, temp->name);
        temp = temp->next;
    }
    return env->NewStringUTF(info);
}

extern "C"
JNIEXPORT jstring JNICALL
Java_com_jeffmony_ffmpeglib_FFmpegInfoUtils_avformatInfo(JNIEnv *env, jclass clazz) {
    char info[40000] = {0};

    av_register_all();

    AVInputFormat *i_temp = av_iformat_next(NULL);
    AVOutputFormat *o_temp = av_oformat_next(NULL);
    while (i_temp != NULL) {
        sprintf(info, "%sInput: %s\n", info, i_temp->name);
        i_temp = i_temp->next;
    }
    while (o_temp != NULL) {
        sprintf(info, "%sOutput: %s\n", info, o_temp->name);
        o_temp = o_temp->next;
    }
    return env->NewStringUTF(info);
}

extern "C"
JNIEXPORT jstring JNICALL
Java_com_jeffmony_ffmpeglib_FFmpegInfoUtils_protocolInfo(JNIEnv *env, jclass clazz) {
    char info[40000] = {0};
    av_register_all();

    struct URLProtocol *pup = NULL;

    struct URLProtocol **p_temp = &pup;
    avio_enum_protocols((void **) p_temp, 0);

    while ((*p_temp) != NULL) {
        sprintf(info, "%sInput: %s\n", info, avio_enum_protocols((void **) p_temp, 0));
    }
    pup = NULL;
    avio_enum_protocols((void **) p_temp, 1);
    while ((*p_temp) != NULL) {
        sprintf(info, "%sInput: %s\n", info, avio_enum_protocols((void **) p_temp, 1));
    }
    return env->NewStringUTF(info);
}
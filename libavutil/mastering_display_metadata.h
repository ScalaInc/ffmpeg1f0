/**
 * Copyright (c) 2016 Neil Birkbeck <neil.birkbeck@gmail.com>
 *
 * This file is part of FFmpeg.
 *
 * FFmpeg is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * FFmpeg is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with FFmpeg; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

#ifndef AVUTIL_MASTERING_DISPLAY_METADATA_H
#define AVUTIL_MASTERING_DISPLAY_METADATA_H

#include "frame.h"
#include "rational.h"


/**
 * Mastering display metadata capable of representing the color volume of
 * the display used to master the content (SMPTE 2086:2014).
 *
 * To be used as payload of a AVFrameSideData or AVPacketSideData with the
 * appropriate type.
 *
 * @note The struct should be allocated with av_mastering_display_metadata_alloc()
 *       and its size is not a part of the public ABI.
 */
typedef struct AVMasteringDisplayMetadata {
    /**
     * CIE 1931 xy chromaticity coords of color primaries (r, g, b order).
     */
    AVRational display_primaries[3][2];

    /**
     * CIE 1931 xy chromaticity coords of white point.
     */
    AVRational white_point[2];

    /**
     * Min luminance of mastering display (cd/m^2).
     */
    AVRational min_luminance;

    /**
     * Max luminance of mastering display (cd/m^2).
     */
    AVRational max_luminance;

    /**
     * MPEG vs JPEG YUV range.
     * It must be accessed using av_frame_get_color_range() and
     * av_frame_set_color_range().
     * - encoding: Set by user
     * - decoding: Set by libavcodec
     */
    enum AVColorRange color_range;

    enum AVColorPrimaries color_primaries;

    enum AVColorTransferCharacteristic color_trc;

    /**
     * YUV colorspace type.
     * It must be accessed using av_frame_get_colorspace() and
     * av_frame_set_colorspace().
     * - encoding: Set by user
     * - decoding: Set by libavcodec
     */
    enum AVColorSpace colorspace;

    enum AVChromaLocation chroma_location;

    /**
     * Flag indicating whether the display primaries (and white point) are set.
     */
    int has_primaries;

    /**
     * Flag indicating whether the luminance (min_ and max_) have been set.
     */
    int has_luminance;

    /**
     * Flag indicating whether the color_range, color_primaries, color_trc, colorspace and chroma_location have been set
     */
    int has_colorspace;
} AVMasteringDisplayMetadata;

/**
 * Allocate an AVMasteringDisplayMetadata structure and set its fields to
 * default values. The resulting struct can be freed using av_freep().
 *
 * @return An AVMasteringDisplayMetadata filled with default values or NULL
 *         on failure.
 */
AVMasteringDisplayMetadata *av_mastering_display_metadata_alloc(void);

/**
 * Allocate a complete AVMasteringDisplayMetadata and add it to the frame.
 *
 * @param frame The frame which side data is added to.
 *
 * @return The AVMasteringDisplayMetadata structure to be filled by caller.
 */
AVMasteringDisplayMetadata *av_mastering_display_metadata_create_side_data(AVFrame *frame);

#endif /* AVUTIL_MASTERING_DISPLAY_METADATA_H */

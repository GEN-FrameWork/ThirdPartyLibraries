#ifndef COMPRESSION_UTILS_PORTABLE_H_
   #define COMPRESSION_UTILS_PORTABLE_H_
   #include <zlib.h>
   #include <stdint.h>
   #include <stddef.h>
   namespace zlib_internal {
   inline uLong GzipExpectedCompressedSize(uLong input_size) {
       return compressBound(input_size) + 18;
   }
   inline uint32_t GetGzipUncompressedSize(const uint8_t *compressed_data, size_t compressed_size) {
       if (compressed_size < 4) return 0;
       const uint8_t *p = compressed_data + compressed_size - 4;
       return (uint32_t)p[0] | ((uint32_t)p[1] << 8) | ((uint32_t)p[2] << 16) | ((uint32_t)p[3] << 24);
   }
   inline int GzipCompressHelper(uint8_t *dest, uLong *dest_length,
                                  const uint8_t *source, uLong source_length,
                                  void*, void*) {
       return compress2(dest, dest_length, source, source_length, Z_DEFAULT_COMPRESSION);
   }
   inline int GzipUncompressHelper(uint8_t *dest, uLong *dest_length,
                                    const uint8_t *source, uLong source_length) {
       return uncompress(dest, dest_length, source, source_length);
   }
   }  // namespace zlib_internal
   #endif  // COMPRESSION_UTILS_PORTABLE_H_

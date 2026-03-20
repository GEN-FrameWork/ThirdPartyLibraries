/* Android config for OpenAL Soft-style manual configuration.
 * Target: Android cross-compile using the Android NDK from Windows.
 *
 * Notes:
 * - Desktop Linux backends (ALSA/OSS/PulseAudio/JACK/PipeWire/RTKit/DBus) are disabled.
 * - OpenSL is enabled by default because it is available with the NDK.
 * - Oboe can be enabled by defining ALSND_ANDROID_USE_OBOE from CMake.
 * - SIMD is selected from target compiler macros, not from the host OS.
 */

/* Define the alignment attribute for externally callable functions. */
#define FORCE_ALIGN

/* Define if deprecated EAX extensions are enabled */
/* #undef ALSOFT_EAX */

/* Define if HRTF data is embedded in the library */
#define ALSOFT_EMBED_HRTF_DATA

/* Define if we have the posix_memalign function */
#define HAVE_POSIX_MEMALIGN

/* Define if we have the _aligned_malloc function */
/* #undef HAVE__ALIGNED_MALLOC */

/* Define if we have the proc_pidpath function */
/* #undef HAVE_PROC_PIDPATH */

/* Define if we have the getopt function */
#if defined(__has_include)
#  if __has_include(<getopt.h>)
#    define HAVE_GETOPT
#  endif
#endif

/* Define if we have DBus/RTKit */
/* #undef HAVE_RTKIT */

/* Define if we have SSE CPU extensions */
#if defined(__i386__) || defined(__x86_64__)
#  if defined(__SSE__)
#    define HAVE_SSE
#  endif
#  if defined(__SSE2__)
#    define HAVE_SSE2
#  endif
#  if defined(__SSE3__)
#    define HAVE_SSE3
#  endif
#  if defined(__SSE4_1__)
#    define HAVE_SSE4_1
#  endif
#endif

/* Define if we have ARM Neon CPU extensions */
#if defined(__aarch64__) || defined(__ARM_NEON) || defined(__ARM_NEON__)
#  define HAVE_NEON
#endif

/* Define if we have the ALSA backend */
/* #undef HAVE_ALSA */

/* Define if we have the OSS backend */
/* #undef HAVE_OSS */

/* Define if we have the PipeWire backend */
/* #undef HAVE_PIPEWIRE */

/* Define if we have the Solaris backend */
/* #undef HAVE_SOLARIS */

/* Define if we have the SndIO backend */
/* #undef HAVE_SNDIO */

/* Define if we have the WASAPI backend */
/* #undef HAVE_WASAPI */

/* Define if we have the DSound backend */
/* #undef HAVE_DSOUND */

/* Define if we have the Windows Multimedia backend */
/* #undef HAVE_WINMM */

/* Define if we have the PortAudio backend */
/* #undef HAVE_PORTAUDIO */

/* Define if we have the PulseAudio backend */
/* #undef HAVE_PULSEAUDIO */

/* Define if we have the JACK backend */
/* #undef HAVE_JACK */

/* Define if we have the CoreAudio backend */
/* #undef HAVE_COREAUDIO */

/* Define if we have the OpenSL backend */
#if !defined(ALSND_ANDROID_USE_OBOE) && !defined(ALSND_ANDROID_DISABLE_OPENSL)
#  define HAVE_OPENSL
#endif

/* Define if we have the Oboe backend */
#if defined(ALSND_ANDROID_USE_OBOE)
#  define HAVE_OBOE
#endif

/* Define if we have the Wave Writer backend */
#define HAVE_WAVE

/* Define if we have the SDL2 backend */
/* #undef HAVE_SDL2 */

/* Define if we have dlfcn.h */
#if defined(__has_include)
#  if __has_include(<dlfcn.h>)
#    define HAVE_DLFCN_H
#  endif
#endif

/* Define if we have pthread_np.h */
#if defined(__has_include)
#  if __has_include(<pthread_np.h>)
#    define HAVE_PTHREAD_NP_H
#  endif
#endif

/* Define if we have malloc.h */
#if defined(__has_include)
#  if __has_include(<malloc.h>)
#    define HAVE_MALLOC_H
#  endif
#endif

/* Define if we have cpuid.h */
#if (defined(__i386__) || defined(__x86_64__)) && defined(__has_include)
#  if __has_include(<cpuid.h>)
#    define HAVE_CPUID_H
#    define HAVE_GCC_GET_CPUID
#  endif
#endif

/* Define if we have intrin.h */
/* #undef HAVE_INTRIN_H */

/* Define if we have guiddef.h */
/* #undef HAVE_GUIDDEF_H */

/* Define if we have initguid.h */
/* #undef HAVE_INITGUID_H */

/* Define if we have the __cpuid() intrinsic */
/* #undef HAVE_CPUID_INTRINSIC */

/* Define if we have SSE intrinsics */
#if defined(__i386__) || defined(__x86_64__)
#  if defined(__SSE__) || defined(__SSE2__) || defined(__SSE3__) || defined(__SSE4_1__)
#    define HAVE_SSE_INTRINSICS
#  endif
#endif

/* Define if we have pthread_setschedparam() */
#define HAVE_PTHREAD_SETSCHEDPARAM

/* Define if we have pthread_setname_np() */
/* #undef HAVE_PTHREAD_SETNAME_NP */

/* Define if we have pthread_set_name_np() */
/* #undef HAVE_PTHREAD_SET_NAME_NP */

/* Define the installation data directory */
/* #undef ALSOFT_INSTALL_DATADIR */

/* Define whether build alsoft for winuwp */
/* #undef ALSOFT_UWP */

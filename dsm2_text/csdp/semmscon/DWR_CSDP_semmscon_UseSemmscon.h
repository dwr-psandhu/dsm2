/* DO NOT EDIT THIS FILE - it is machine generated */
#include <jni.h>
/* Header for class DWR_CSDP_semmscon_UseSemmscon */

#ifndef _Included_DWR_CSDP_semmscon_UseSemmscon
#define _Included_DWR_CSDP_semmscon_UseSemmscon
#ifdef __cplusplus
extern "C" {
#endif
/*
 * Class:     DWR_CSDP_semmscon_UseSemmscon
 * Method:    init_convert
 * Signature: ()V
 */
JNIEXPORT void JNICALL Java_DWR_CSDP_semmscon_UseSemmscon_init_1convert
  (JNIEnv *, jobject);

/*
 * Class:     DWR_CSDP_semmscon_UseSemmscon
 * Method:    utm83ToUtm27
 * Signature: (DDSSSS)[D
 */
JNIEXPORT jdoubleArray JNICALL Java_DWR_CSDP_semmscon_UseSemmscon_utm83ToUtm27
  (JNIEnv *, jobject, jdouble, jdouble, jshort, jshort, jshort, jshort);

/*
 * Class:     DWR_CSDP_semmscon_UseSemmscon
 * Method:    utm27ToUtm83
 * Signature: (DDSSSS)[D
 */
JNIEXPORT jdoubleArray JNICALL Java_DWR_CSDP_semmscon_UseSemmscon_utm27ToUtm83
  (JNIEnv *, jobject, jdouble, jdouble, jshort, jshort, jshort, jshort);

/*
 * Class:     DWR_CSDP_semmscon_UseSemmscon
 * Method:    ngvd29_to_navd88_utm83
 * Signature: (DDSSDSS)D
 */
JNIEXPORT jdouble JNICALL Java_DWR_CSDP_semmscon_UseSemmscon_ngvd29_1to_1navd88_1utm83
  (JNIEnv *, jobject, jdouble, jdouble, jshort, jshort, jdouble, jshort, jshort);

/*
 * Class:     DWR_CSDP_semmscon_UseSemmscon
 * Method:    navd88_to_ngvd29_utm83
 * Signature: (DDSSDSS)D
 */
JNIEXPORT jdouble JNICALL Java_DWR_CSDP_semmscon_UseSemmscon_navd88_1to_1ngvd29_1utm83
  (JNIEnv *, jobject, jdouble, jdouble, jshort, jshort, jdouble, jshort, jshort);

/*
 * Class:     DWR_CSDP_semmscon_UseSemmscon
 * Method:    ngvd29_to_navd88_utm27
 * Signature: (DDSSDSS)D
 */
JNIEXPORT jdouble JNICALL Java_DWR_CSDP_semmscon_UseSemmscon_ngvd29_1to_1navd88_1utm27
  (JNIEnv *, jobject, jdouble, jdouble, jshort, jshort, jdouble, jshort, jshort);

/*
 * Class:     DWR_CSDP_semmscon_UseSemmscon
 * Method:    navd88_to_ngvd29_utm27
 * Signature: (DDSSDSS)D
 */
JNIEXPORT jdouble JNICALL Java_DWR_CSDP_semmscon_UseSemmscon_navd88_1to_1ngvd29_1utm27
  (JNIEnv *, jobject, jdouble, jdouble, jshort, jshort, jdouble, jshort, jshort);

#ifdef __cplusplus
}
#endif
#endif

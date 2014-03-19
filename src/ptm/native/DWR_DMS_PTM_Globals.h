/* DO NOT EDIT THIS FILE - it is machine generated */
#include <jni.h>
/* Header for class DWR_DMS_PTM_Globals */

#ifndef _Included_DWR_DMS_PTM_Globals
#define _Included_DWR_DMS_PTM_Globals
#ifdef __cplusplus
extern "C" {
#endif
/* Inaccessible static: currentModelTime */
/* Inaccessible static: currentMilitaryTime */
/* Inaccessible static: Environment */
#undef DWR_DMS_PTM_Globals_ASCII
#define DWR_DMS_PTM_Globals_ASCII 1L
#undef DWR_DMS_PTM_Globals_BINARY
#define DWR_DMS_PTM_Globals_BINARY 2L
/*
 * Class:     DWR_DMS_PTM_Globals
 * Method:    getModelDate
 * Signature: (I)Ljava/lang/String;
 */
JNIEXPORT jstring JNICALL Java_DWR_DMS_PTM_Globals_getModelDate
  (JNIEnv *, jclass, jint);

/*
 * Class:     DWR_DMS_PTM_Globals
 * Method:    getModelTime
 * Signature: (I)Ljava/lang/String;
 */
JNIEXPORT jstring JNICALL Java_DWR_DMS_PTM_Globals_getModelTime
  (JNIEnv *, jclass, jint);

/*
 * Class:     DWR_DMS_PTM_Globals
 * Method:    getTimeInJulianMins
 * Signature: (Ljava/lang/String;Ljava/lang/String;)I
 */
JNIEXPORT jint JNICALL Java_DWR_DMS_PTM_Globals_getTimeInJulianMins
  (JNIEnv *, jclass, jstring, jstring);

#ifdef __cplusplus
}
#endif
#endif

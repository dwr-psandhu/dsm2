/* DO NOT EDIT THIS FILE - it is machine generated */
#include <jni.h>
/* Header for class DWR_DMS_PTM_PTMHydroInput */

#ifndef _Included_DWR_DMS_PTM_PTMHydroInput
#define _Included_DWR_DMS_PTM_PTMHydroInput
#ifdef __cplusplus
extern "C" {
#endif
#undef DWR_DMS_PTM_PTMHydroInput_DEBUG
#define DWR_DMS_PTM_PTMHydroInput_DEBUG 0L
/*
 * Class:     DWR_DMS_PTM_PTMHydroInput
 * Method:    readMultTide
 * Signature: (I)V
 */
JNIEXPORT void JNICALL Java_DWR_DMS_PTM_PTMHydroInput_readMultTide
  (JNIEnv *, jobject, jint);

/*
 * Class:     DWR_DMS_PTM_PTMHydroInput
 * Method:    getExtFromInt
 * Signature: (I)I
 */
JNIEXPORT jint JNICALL Java_DWR_DMS_PTM_PTMHydroInput_getExtFromInt
  (JNIEnv *, jobject, jint);

/*
 * Class:     DWR_DMS_PTM_PTMHydroInput
 * Method:    getUpNodeDepth
 * Signature: (I)F
 */
JNIEXPORT jfloat JNICALL Java_DWR_DMS_PTM_PTMHydroInput_getUpNodeDepth
  (JNIEnv *, jobject, jint);

/*
 * Class:     DWR_DMS_PTM_PTMHydroInput
 * Method:    getDownNodeDepth
 * Signature: (I)F
 */
JNIEXPORT jfloat JNICALL Java_DWR_DMS_PTM_PTMHydroInput_getDownNodeDepth
  (JNIEnv *, jobject, jint);

/*
 * Class:     DWR_DMS_PTM_PTMHydroInput
 * Method:    getUpNodeStage
 * Signature: (I)F
 */
JNIEXPORT jfloat JNICALL Java_DWR_DMS_PTM_PTMHydroInput_getUpNodeStage
  (JNIEnv *, jobject, jint);

/*
 * Class:     DWR_DMS_PTM_PTMHydroInput
 * Method:    getDownNodeStage
 * Signature: (I)F
 */
JNIEXPORT jfloat JNICALL Java_DWR_DMS_PTM_PTMHydroInput_getDownNodeStage
  (JNIEnv *, jobject, jint);

/*
 * Class:     DWR_DMS_PTM_PTMHydroInput
 * Method:    getUpNodeFlow
 * Signature: (I)F
 */
JNIEXPORT jfloat JNICALL Java_DWR_DMS_PTM_PTMHydroInput_getUpNodeFlow
  (JNIEnv *, jobject, jint);

/*
 * Class:     DWR_DMS_PTM_PTMHydroInput
 * Method:    getDownNodeFlow
 * Signature: (I)F
 */
JNIEXPORT jfloat JNICALL Java_DWR_DMS_PTM_PTMHydroInput_getDownNodeFlow
  (JNIEnv *, jobject, jint);

/*
 * Class:     DWR_DMS_PTM_PTMHydroInput
 * Method:    getUpNodeArea
 * Signature: (I)F
 */
JNIEXPORT jfloat JNICALL Java_DWR_DMS_PTM_PTMHydroInput_getUpNodeArea
  (JNIEnv *, jobject, jint);

/*
 * Class:     DWR_DMS_PTM_PTMHydroInput
 * Method:    getDownNodeArea
 * Signature: (I)F
 */
JNIEXPORT jfloat JNICALL Java_DWR_DMS_PTM_PTMHydroInput_getDownNodeArea
  (JNIEnv *, jobject, jint);

/*
 * Class:     DWR_DMS_PTM_PTMHydroInput
 * Method:    getFlowForWaterbodyNode
 * Signature: (II)F
 */
JNIEXPORT jfloat JNICALL Java_DWR_DMS_PTM_PTMHydroInput_getFlowForWaterbodyNode
  (JNIEnv *, jobject, jint, jint);

/*
 * Class:     DWR_DMS_PTM_PTMHydroInput
 * Method:    getReservoirVolume
 * Signature: (I)F
 */
JNIEXPORT jfloat JNICALL Java_DWR_DMS_PTM_PTMHydroInput_getReservoirVolume
  (JNIEnv *, jobject, jint);

/*
 * Class:     DWR_DMS_PTM_PTMHydroInput
 * Method:    getNodeNumberForConnection
 * Signature: (II)I
 */
JNIEXPORT jint JNICALL Java_DWR_DMS_PTM_PTMHydroInput_getNodeNumberForConnection
  (JNIEnv *, jobject, jint, jint);

/*
 * Class:     DWR_DMS_PTM_PTMHydroInput
 * Method:    getReservoirDepth
 * Signature: (I)F
 */
JNIEXPORT jfloat JNICALL Java_DWR_DMS_PTM_PTMHydroInput_getReservoirDepth
  (JNIEnv *, jobject, jint);

/*
 * Class:     DWR_DMS_PTM_PTMHydroInput
 * Method:    getReservoirFlowForConnection
 * Signature: (II)F
 */
JNIEXPORT jfloat JNICALL Java_DWR_DMS_PTM_PTMHydroInput_getReservoirFlowForConnection
  (JNIEnv *, jobject, jint, jint);

/*
 * Class:     DWR_DMS_PTM_PTMHydroInput
 * Method:    getDiversionAtNode
 * Signature: (I)F
 */
JNIEXPORT jfloat JNICALL Java_DWR_DMS_PTM_PTMHydroInput_getDiversionAtNode
  (JNIEnv *, jobject, jint);

/*
 * Class:     DWR_DMS_PTM_PTMHydroInput
 * Method:    getReservoirPumping
 * Signature: (I)F
 */
JNIEXPORT jfloat JNICALL Java_DWR_DMS_PTM_PTMHydroInput_getReservoirPumping
  (JNIEnv *, jobject, jint);

/*
 * Class:     DWR_DMS_PTM_PTMHydroInput
 * Method:    getBoundaryFlow
 * Signature: (I)F
 */
JNIEXPORT jfloat JNICALL Java_DWR_DMS_PTM_PTMHydroInput_getBoundaryFlow
  (JNIEnv *, jobject, jint);

/*
 * Class:     DWR_DMS_PTM_PTMHydroInput
 * Method:    getStageBoundaryFlow
 * Signature: (I)F
 */
JNIEXPORT jfloat JNICALL Java_DWR_DMS_PTM_PTMHydroInput_getStageBoundaryFlow
  (JNIEnv *, jobject, jint);

/*
 * Class:     DWR_DMS_PTM_PTMHydroInput
 * Method:    getConveyorFlow
 * Signature: (I)F
 */
JNIEXPORT jfloat JNICALL Java_DWR_DMS_PTM_PTMHydroInput_getConveyorFlow
  (JNIEnv *, jobject, jint);

/*
 * Class:     DWR_DMS_PTM_PTMHydroInput
 * Method:    updateOpsOfFilters
 * Signature: ()V
 */
JNIEXPORT void JNICALL Java_DWR_DMS_PTM_PTMHydroInput_updateOpsOfFilters
  (JNIEnv *, jobject);

/*
 * Class:     DWR_DMS_PTM_PTMHydroInput
 * Method:    getOpOfFilter
 * Signature: (I)F
 */
JNIEXPORT jfloat JNICALL Java_DWR_DMS_PTM_PTMHydroInput_getOpOfFilter
  (JNIEnv *, jobject, jint);

/*
 * Class:     DWR_DMS_PTM_PTMHydroInput
 * Method:    getUpNodeQuality
 * Signature: (II)F
 */
JNIEXPORT jfloat JNICALL Java_DWR_DMS_PTM_PTMHydroInput_getUpNodeQuality
  (JNIEnv *, jobject, jint, jint);

/*
 * Class:     DWR_DMS_PTM_PTMHydroInput
 * Method:    getDownNodeQuality
 * Signature: (II)F
 */
JNIEXPORT jfloat JNICALL Java_DWR_DMS_PTM_PTMHydroInput_getDownNodeQuality
  (JNIEnv *, jobject, jint, jint);

#ifdef __cplusplus
}
#endif
#endif

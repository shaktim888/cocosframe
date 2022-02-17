#ifndef startCC_h
#define startCC_h

#if defined(__cplusplus)
extern "C" void startCC(void);
extern "C" id startBB(void);
#else
extern void startCC(void);
extern id startBB(void);
#endif

#endif /* startCC_h */

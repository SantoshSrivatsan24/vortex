#pragma once

#include "types.h"

namespace vortex {

class Warp;

enum Opcode {   
  NOP       = 0,    
  R_INST    = 0x33,
  L_INST    = 0x3,
  I_INST    = 0x13,
  S_INST    = 0x23,
  B_INST    = 0x63,
  LUI_INST  = 0x37,
  AUIPC_INST= 0x17,
  JAL_INST  = 0x6f,
  JALR_INST = 0x67,
  SYS_INST  = 0x73,
  FENCE     = 0x0f,
  // F Extension
  FL        = 0x7,
  FS        = 0x27,
  FCI       = 0x53,
  FMADD     = 0x43,
  FMSUB     = 0x47,
  FMNMSUB   = 0x4b,
  FMNMADD   = 0x4f,
  // Vector Extension  
  VSET      = 0x57,
  VL        = 0x7,
  VS        = 0x27,
  // GPGPU Extension
  GPGPU     = 0x6b,
  // simx64
  // RV64I Extension
  R_INST_64 = 0x3b,
  I_INST_64 = 0x1b,
};

enum InstType { 
  N_TYPE, 
  R_TYPE, 
  I_TYPE, 
  S_TYPE, 
  B_TYPE, 
  U_TYPE, 
  J_TYPE,
  V_TYPE,
  R4_TYPE
};

class Instr {
public:
  Instr() 
    : opcode_(Opcode::NOP)
    , num_rsrcs_(0)
    , has_imm_(false)
    , rdest_(0)
    , func3_(0)
    , func7_(0) {
    for (int i = 0; i < MAX_REG_SOURCES; ++i) {
       rsrc_type_[i] = 0;
    }
  }

  /* Setters used to "craft" the instruction. */
  void setOpcode(Opcode opcode)  { opcode_ = opcode; }
  void setDestReg(int destReg) { rdest_type_ = 1; rdest_ = destReg; }
  void setSrcReg(int srcReg) { rsrc_type_[num_rsrcs_] = 1; rsrc_[num_rsrcs_++] = srcReg; }
  void setDestFReg(int destReg) { rdest_type_ = 2; rdest_ = destReg; }
  void setSrcFReg(int srcReg) { rsrc_type_[num_rsrcs_] = 2; rsrc_[num_rsrcs_++] = srcReg;  }
  void setDestVReg(int destReg) { rdest_type_ = 3; rdest_ = destReg; }
  void setSrcVReg(int srcReg) { rsrc_type_[num_rsrcs_] = 3; rsrc_[num_rsrcs_++] = srcReg;  }
  void setFunc3(Word32 func3) { func3_ = func3; }
  void setFunc7(Word32 func7) { func7_ = func7; }
  void setImm(Word32 imm) { has_imm_ = true; imm_ = imm; }
  void setVlsWidth(Word32 width) { vlsWidth_ = width; }
  void setVmop(Word32 mop) { vMop_ = mop; }
  void setVnf(Word32 nf) { vNf_ = nf; }
  void setVmask(Word32 mask) { vmask_ = mask; }
  void setVs3(Word32 vs) { vs3_ = vs; }
  void setVlmul(Word32 lmul) { vlmul_ = 1 << lmul; }
  void setVsew(Word32 sew) { vsew_ = 1 << (3+sew); }
  void setVediv(Word32 ediv) { vediv_ = 1 << ediv; }
  void setFunc6(Word32 func6) { func6_ = func6; }

  /* Getters used by encoders. */
  //TODO KA: To discuss. Is it necessary to use Word32 as return value? Maybe uint32_t matches best?
  Opcode getOpcode() const { return opcode_; }
  Word32 getFunc3() const { return func3_; }
  Word32 getFunc6() const { return func6_; }
  Word32 getFunc7() const { return func7_; }
  int getNRSrc() const { return num_rsrcs_; }
  int getRSrc(int i) const { return rsrc_[i]; }
  int getRSType(int i) const { return rsrc_type_[i]; }
  int getRDest() const { return rdest_; }  
  int getRDType() const { return rdest_type_; }  
  bool hasImm() const { return has_imm_; }
  Word32 getImm() const { return imm_; }
  Word32 getVlsWidth() const { return vlsWidth_; }
  Word32 getVmop() const { return vMop_; }
  Word32 getvNf() const { return vNf_; }
  Word32 getVmask() const { return vmask_; }
  Word32 getVs3() const { return vs3_; }
  Word32 getVlmul() const { return vlmul_; }
  Word32 getVsew() const { return vsew_; }
  Word32 getVediv() const { return vediv_; }

private:

  enum {
    MAX_REG_SOURCES = 3
  };

  //TODO KA: There are unused fields: isrc_mask_, fsrc_mask_, vsrc_mask_
  Opcode opcode_;
  int num_rsrcs_;
  bool has_imm_;
  int rdest_type_;
  int isrc_mask_;
  int fsrc_mask_;  
  int vsrc_mask_;
  Word32 imm_;
  int rsrc_type_[MAX_REG_SOURCES];
  int rsrc_[MAX_REG_SOURCES];  
  int rdest_;
  Word32 func3_;
  Word32 func7_;

  //Vector
  Word32 vmask_;
  Word32 vlsWidth_;
  Word32 vMop_;
  Word32 vNf_;
  Word32 vs3_;
  Word32 vlmul_;
  Word32 vsew_;
  Word32 vediv_;
  Word32 func6_;

  friend std::ostream &operator<<(std::ostream &, const Instr&);
};

}
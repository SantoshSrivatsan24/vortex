#pragma once

#include <vector>
#include <memory>

namespace vortex {

class ArchDef;
class Instr;
class Pipeline;

class Decoder {
public:
  Decoder(const ArchDef &);    
  
  std::shared_ptr<Instr> decode(uint32_t code, uint64_t PC);

private:
//TODO KA: change types
  Word32 inst_s_;
  Word32 opcode_s_;
  Word32 reg_s_;
  Word32 func2_s_;
  Word32 func3_s_;
  Word32 shift_opcode_;
  Word32 shift_rd_;
  Word32 shift_rs1_;
  Word32 shift_rs2_;
  Word32 shift_rs3_;
  Word32 shift_func2_;
  Word32 shift_func3_;
  Word32 shift_func7_;
  Word32 shift_j_u_immed_;
  Word32 shift_s_b_immed_;
  Word32 shift_i_immed_;

  Word32 reg_mask_;
  Word32 func2_mask_;
  Word32 func3_mask_;
  Word32 func6_mask_;
  Word32 func7_mask_;
  Word32 opcode_mask_;
  Word32 i_imm_mask_;
  Word32 s_imm_mask_;
  Word32 b_imm_mask_;
  Word32 u_imm_mask_;
  Word32 j_imm_mask_;
  Word32 v_imm_mask_;

  //Vector
  Word32 shift_vset_;
  Word32 shift_vset_immed_;
  Word32 shift_vmask_;
  Word32 shift_vmop_;
  Word32 shift_vnf_;
  Word32 shift_func6_;
  Word32 vmask_s_;
  Word32 mop_s_;
};

}
#ifndef __WARP_H
#define __WARP_H

#include <vector>
#include <stack>
#include "types.h"

namespace vortex {

class Core;
class Instr;
class Pipeline;
struct DomStackEntry {
  DomStackEntry(const ThreadMask &tmask, Word64 PC)
    : tmask(tmask)
    , PC(PC)
    , fallThrough(false)
    , unanimous(false) 
  {}

  DomStackEntry(const ThreadMask &tmask)
      : tmask(tmask)
      , PC(0)
      , fallThrough(true)
      , unanimous(false) 
  {}

  ThreadMask tmask;
  Word64 PC;
  bool fallThrough;
  bool unanimous;
};
// TODO KA: again unused code
struct vtype {
  int vill;
  int vediv;
  int vsew;
  int vlmul;
};

/// TODO KA: What do Wrap means?
class Warp {
public:
  Warp(Core *core, Word32 id);

  void clear();
  
  bool active() const {
    return active_;
  }

  void activate() {
    active_ = true;
  }

  std::size_t getActiveThreads() const {
    if (active_)
      return tmask_.count();
    return 0;
  }

  Word32 id() const {
    return id_;
  }

  Word64 getPC() const {
    return PC_;
  }

  void setPC(Word64 PC) {
    PC_ = PC;
  }

  void setTmask(size_t index, bool value) {
    tmask_[index] = value;
    active_ = tmask_.any();
  }

  Word64 getTmask() const {
    if (active_)
      return tmask_.to_ulong();
    return 0;
  }

  Word64 getIRegValue(int reg) const {
    return iRegFile_[0][reg];
  }

  void step(Pipeline *);

private:

  void execute(const Instr &instr, Pipeline *);
  
  Word32 id_;
  bool active_;
  Core *core_;
  
  Word64 PC_;
  ThreadMask tmask_;  
  
  // simx64
  std::vector<std::vector<Word64>> iRegFile_;
  std::vector<std::vector<Word64>> fRegFile_;
  std::vector<std::vector<Byte>> vRegFile_;
  std::stack<DomStackEntry> domStack_;

  struct vtype vtype_;
  int vl_;
};

}

#endif
#include "util/TStringConversion.h"
#include "util/TBufStream.h"
#include "util/TIfstream.h"
#include "util/TOfstream.h"
#include "util/TThingyTable.h"
#include "exception/TGenericException.h"
#include <string>
#include <fstream>
#include <sstream>
#include <iostream>

using namespace std;
using namespace BlackT;

const static int op_terminator = 0x00;
const static int op_wait       = 0xFD;
const static int op_flags      = 0xFE;
const static int op_br         = 0xFF;
//const static int op_waitend    = 0xFD00;

const static int numRegion0Strings = 0x73;
const static int numRegion1Strings = 0x35;
const static int numRegion2Strings = 0x76;
const static int numRegion3Strings = 0x2C;
const static int numRegion4Strings = 0xF;
const static int numRegion5Strings = 0x16;
const static int numRegion6Strings = 0x9F;
const static int numRegion7Strings = 0x7C;
const static int numRegion8Strings = 0x37;
const static int numRegion9Strings = 0x48;
const static int numRegion10Strings = 0x5;

const static int region_locTable_addr = 0x1A069;
//const static int dictionaryTableBase = 0xe75e;

int smsBankSize = 0x4000;

string as2bHex(int num) {
  string str = TStringConversion::intToString(num,
                  TStringConversion::baseHex).substr(2, string::npos);
  while (str.size() < 2) str = string("0") + str;
  
  return "<$" + str + ">";
}

void outputComment(std::ostream& ofs,
               string comment = "") {
  if (comment.size() > 0) {
    ofs << "//=======================================" << endl;
    ofs << "// " << comment << endl;
    ofs << "//=======================================" << endl;
    ofs << endl;
  }
}

int numOpParamBytes(int op) {
  switch (op) {
  case op_flags:
    return 1;
    break;
  default:
    break;
  }
  
  return 0;
}

bool isSharedOp(int op) {
  switch (op) {
  case op_br:
    return false;
    break;
  default:
    break;
  }
  
  return true;
}

// number of linebreaks that should precede an op type
int numOpPreLines(int op) {
  switch (op) {
  case op_wait:
    return 1;
    break;
  default:
    break;
  }
  
  return 0;
}

// number of linebreaks that should follow an op type
int numOpPostLines(int op) {
  switch (op) {
  case op_br:
    return 1;
    break;
  case op_wait:
  case op_terminator:
//  case op_waitend:
    return 2;
    break;
  default:
    break;
  }
  
  if (isSharedOp(op)) return 1;
  
  return 0;
}

void dumpSubstring(TStream& ifs, std::ostream& ofs, const TThingyTable& table,
                   int offset) {
//  std::cerr << hex << offset << endl;
  ifs.seek(offset);
  while (true) {
    TThingyTable::MatchResult result = table.matchId(ifs);
    if (result.id == -1) {
      throw TGenericException(T_SRCANDLINE,
                              "dumpSubstring(TStream&, std::ostream&)",
                              string("At offset ")
                                + TStringConversion::intToString(
                                    ifs.tell(),
                                    TStringConversion::baseHex)
                                + ": unknown character '"
                                + TStringConversion::intToString(
                                    (unsigned char)ifs.peek(),
                                    TStringConversion::baseHex)
                                + "'");
    }
    
    string resultStr = table.getEntry(result.id);
    
    if ((result.id == op_terminator)) {
      break;
    }
    
    ofs << resultStr;
  }
}

void dumpString(TStream& ifs, std::ostream& ofs, const TThingyTable& table,
              int offset, int slot,
              int autowrap = -1,
              string comment = "") {
  ifs.seek(offset);
  
  std::ostringstream oss_final;
  std::ostringstream oss_textline;
  
  if (comment.size() > 0)
    oss_final << "// " << comment << endl;
  
  bool atLineStart = true;
  bool lastWasBr = false;
  int charsOnLine = 0;
  while (!ifs.eof()) {
    TThingyTable::MatchResult result = table.matchId(ifs);
    if (result.id == -1) {
      throw TGenericException(T_SRCANDLINE,
                              "dumpScript()",
                              string("At file offset ")
                                + TStringConversion::intToString(
                                    ifs.tell(),
                                    TStringConversion::baseHex)
                                + ": could not match character from table");
    }
    
    int id = result.id;
    string resultStr = table.getEntry(result.id);
    bool isOp = (id == 0x00)
                  || ((id >= 0xFD) && (id <= 0xFF));
//                  || (id == op_waitend)
    
    if (isOp) {
      bool shared = isSharedOp(id);
      
      std::ostringstream* targetOss = NULL;
      if (shared) {
        targetOss = &oss_final;
        
        // empty comment line buffer
        if (oss_textline.str().size() > 0) {
          oss_final << "// " << oss_textline.str();
          oss_final << std::endl << std::endl;
          oss_textline.str("");
          atLineStart = true;
        }
      }
      else {
        targetOss = &oss_textline;
      }
      
      //===========================================
      // output pre-linebreaks
      //===========================================
      
      int numPreLines = numOpPreLines(id);
      if ((!atLineStart || (atLineStart && lastWasBr))
          && (numPreLines > 0)) {
        if (oss_textline.str().size() > 0) {
          oss_final << "// " << oss_textline.str();
          oss_textline.str("");
        }
        
        for (int i = 0; i < numPreLines; i++) {
          oss_final << std::endl;
        }

        atLineStart = true;
      }
      
      //===========================================
      // if op is shared, output it directly to
      // the final text on its own line, separate
      // from the commented-out original
      //===========================================
      
      // non-shared op: add to commented-out original line
      *targetOss << resultStr;
      atLineStart = false;
      
      //===========================================
      // output param bytes
      //===========================================
      
      int numParamBytes = numOpParamBytes(id);
      for (int i = 0; i < numParamBytes; i++) {
        *targetOss << as2bHex(ifs.readu8());
        atLineStart = false;
      }
      
      //===========================================
      // output post-linebreaks
      //===========================================
     
      int numPostLines = numOpPostLines(id);
      
      // HACK: hack for wait/end combo
      if ((id == op_wait) && ((unsigned char)ifs.peek() == op_terminator)) {
        numPostLines = 1;
      }
      
      if (numPostLines > 0) {
        if (oss_textline.str().size() > 0) {
          oss_final << "// " << oss_textline.str();
          oss_textline.str("");
        }
       
        for (int i = 0; i < numPostLines; i++) {
          oss_final << std::endl;
        }

        atLineStart = true;
      }
    }
    else {
      // account for auto-break every 7 chars
      ++charsOnLine;
      if ((autowrap != -1) && (charsOnLine > autowrap)) {
        oss_final << "// " << oss_textline.str();
        oss_textline.str("");
        oss_final << std::endl;
        charsOnLine = 0;
        atLineStart = true;
      }
      
      // not an op: add to commented-out original line
      oss_textline << resultStr;
      
      atLineStart = false;
    }
    
    // check for terminators
    if ((id == op_terminator)) {
      break;
    }
    
    // handle line-breaking ops
    if ((id == op_br) || (id == op_wait)) charsOnLine = 0;
    
    lastWasBr = (id == op_br);
  }
  
  ofs << "#STARTMSG("
      // offset
      << TStringConversion::intToString(
          offset, TStringConversion::baseHex)
      << ", "
      // size
      << TStringConversion::intToString(
          ifs.tell() - offset, TStringConversion::baseDec)
      << ", "
      // slot num
      << TStringConversion::intToString(
          slot, TStringConversion::baseDec)
      << ")" << endl << endl;
  
//  ofs << oss.str();
  ofs << oss_final.str();
  
//  ofs << endl;
  ofs << "#ENDMSG()";
  ofs << endl << endl;
}

void dumpStringSet(TStream& ifs, std::ostream& ofs, const TThingyTable& table,
               int startOffset, int slot,
               int numStrings,
               string comment = "") {
  if (comment.size() > 0) {
    ofs << "//=======================================" << endl;
    ofs << "// " << comment << endl;
    ofs << "//=======================================" << endl;
    ofs << endl;
  }
  
  ifs.seek(startOffset);
  for (int i = 0; i < numStrings; i++) {
    ofs << "// substring " << i << endl;
    dumpString(ifs, ofs, table, ifs.tell(), slot, 7, "");
  }
}

void dumpTilemap(TStream& ifs, std::ostream& ofs, int offset, int slot,
              TThingyTable& tbl, int w, int h,
              bool isHalved = true,
              string comment = "") {
  ifs.seek(offset);
  
  std::ostringstream oss;
  
  if (comment.size() > 0)
    oss << "// " << comment << endl;
  
  // comment out first line of original text
  oss << "// ";
  for (int j = 0; j < h; j++) {
    for (int i = 0; i < w; i++) {
    
//      TThingyTable::MatchResult result = tbl.matchId(ifs);
      
      TByte next = ifs.get();
      if (!tbl.hasEntry(next)) {
        throw TGenericException(T_SRCANDLINE,
                                "dumpTilemap()",
                                string("At offset ")
                                  + TStringConversion::intToString(
                                      ifs.tell() - 1,
                                      TStringConversion::baseHex)
                                  + ": unknown character '"
                                  + TStringConversion::intToString(
                                      (unsigned char)next,
                                      TStringConversion::baseHex)
                                  + "'");
      }
      
//      string resultStr = tbl.getEntry(result.id);
      string resultStr = tbl.getEntry(next);
      oss << resultStr;
      
      if (!isHalved) ifs.get();
    }
    
    // end of line
    oss << endl;
    oss << "// ";
  }
  
//  oss << endl << endl << "[end]";
  
  ofs << "#STARTMSG("
      // offset
      << TStringConversion::intToString(
          offset, TStringConversion::baseHex)
      << ", "
      // size
      << TStringConversion::intToString(
          ifs.tell() - offset, TStringConversion::baseDec)
      << ", "
      // slot num
      << TStringConversion::intToString(
          slot, TStringConversion::baseDec)
      << ")" << endl << endl;
  
  ofs << oss.str();
  
//  oss << endl;
  ofs << endl << endl;
//  ofs << "//   end pos: "
//      << TStringConversion::intToString(
//          ifs.tell(), TStringConversion::baseHex)
//      << endl;
//  ofs << "//   size: " << ifs.tell() - offset << endl;
  ofs << endl;
  ofs << "#ENDMSG()";
  ofs << endl << endl;
}

void dumpTilemapSet(TStream& ifs, std::ostream& ofs, int startOffset, int slot,
               TThingyTable& tbl, int w, int h,
               int numTilemaps,
               bool isHalved = true,
               string comment = "") {
  if (comment.size() > 0) {
    ofs << "//=======================================" << endl;
    ofs << "// " << comment << endl;
    ofs << "//=======================================" << endl;
    ofs << endl;
  }
  
  ifs.seek(startOffset);
  for (int i = 0; i < numTilemaps; i++) {
    ofs << "// tilemap " << i << endl;
    dumpTilemap(ifs, ofs, ifs.tell(), slot, tbl, w, h, isHalved);
  }
}

void addComment(std::ostream& ofs, string comment) {
  ofs << "//===========================================================" << endl;
  ofs << "// " << comment << endl;
  ofs << "//===========================================================" << endl;
  ofs << endl;
}

/*const static int region_baseBank_default = 3;
const static int region_baseBank_region2 = 5;
const static int region_baseBank_region4 = 6;

int getRegionBaseBank(int regionNum) {
  switch (regionNum) {
  case 2: return region_baseBank_region2;
  case 4: return region_baseBank_region4;
  default: return region_baseBank_default;
  }
} */

void dumpRegionString(TStream& ifs, std::ostream& ofs, TThingyTable& table,
                      int regionNum, int scriptNum) {
  // skip invalid stuff in tables
  if ((regionNum == 3) && (scriptNum == 0x25)) {
    ofs << "#STARTMSG("
        // offset
        << TStringConversion::intToString(
            0, TStringConversion::baseHex)
        << ", "
        // size
        << TStringConversion::intToString(
            0, TStringConversion::baseDec)
        << ", "
        // slot num
        << TStringConversion::intToString(
            1, TStringConversion::baseDec)
        << ")" << endl << endl;
    
    ofs << endl;
    ofs << "#ENDMSG()";
    ofs << endl << endl;
    
    return;
  }
  
//  int baseBank = getRegionBaseBank(regionNum);
  ifs.seek(region_locTable_addr + (regionNum * 2));
  int rsrcId = ifs.readu8();
  int baseBank = ifs.readu8();
  
  int bankBaseAddr = baseBank * smsBankSize;
  ifs.seek(bankBaseAddr + 4 + (rsrcId * 2));
  int regionTablePtr = ifs.readu16le();
  int regionTableAddr = bankBaseAddr + (regionTablePtr - (smsBankSize * 1));
  
  ifs.seek(regionTableAddr + (scriptNum * 2));
  int scriptPtr = ifs.readu16le();
  int scriptAddr = bankBaseAddr + (scriptPtr - (smsBankSize * 1));
  
//  std::cerr << regionNum << " " << hex << " " << regionLoc << " " << regionBaseAddr << std::endl;
//  ifs.seek(regionBaseAddr);
//  int temp = ifs.readu16le();
//  std::cerr << hex << (temp / 2) << endl;
//  cerr << "region " << regionNum << ": " << hex << scriptNum << " "
//      << hex << regionTableAddr + (scriptNum * 2) << " "
//      << hex << scriptAddr << endl;
  
  ofs << "// script "
    << TStringConversion::intToString(regionNum, TStringConversion::baseDec)
    << "-"
    << TStringConversion::intToString(scriptNum, TStringConversion::baseHex)
    << endl;
  
/*  if (scriptOffset == 0) {
    ofs << "//empty" << endl
        << "#ENDMSG()" << endl << endl;
    return;
  } */
  
  // dump target script
  dumpString(ifs, ofs, table, scriptAddr, 1, 7);
}

void dumpPointerTable(TStream& ifs, std::ostream& ofs, TThingyTable& table,
                int offset, int slot, int numScripts) {
  addComment(ofs,
    std::string("Pointer table ")
      + TStringConversion::intToString(offset, TStringConversion::baseHex));
      
//  ofs << "#STARTREGION(" << regionNum << ")" << endl << endl;

  int bankBase = (offset / smsBankSize) * smsBankSize;
  
  for (int i = 0; i < numScripts; i++) {
    int pointerOffset = (offset + (i * 2));
    ifs.seek(pointerOffset);
    int ptr = ifs.readu16le();
    int addr = (ptr - (smsBankSize * slot)) + bankBase;
    dumpString(ifs, ofs, table, addr, slot);
//    dumpRegionString(ifs, ofs, table, regionNum, i);
  }
}

void dumpRegion(TStream& ifs, std::ostream& ofs, TThingyTable& table,
                int regionNum, int numScripts) {
  addComment(ofs,
    std::string("Region ") + TStringConversion::intToString(regionNum));
  ofs << "#STARTREGION(" << regionNum << ")" << endl << endl;
  for (int i = 0; i < numScripts; i++) {
    dumpRegionString(ifs, ofs, table, regionNum, i);
  }
  ofs << "#ENDREGION(" << regionNum << ")" << endl << endl;
}

int main(int argc, char* argv[]) {
  if (argc < 3) {
    cout << "Madou Monogatari A (Game Gear) script dumper" << endl;
    cout << "Usage: " << argv[0] << " [rom] [outprefix]" << endl;
    
    return 0;
  }
  
  string romName = string(argv[1]);
//  string tableName = string(argv[2]);
  string outPrefix = string(argv[2]);
  
  TBufStream ifs;
  ifs.open(romName.c_str());
  
  TThingyTable tablestd;
  tablestd.readSjis(string("table/madoua.tbl"));
  
  try
  {
    {
      std::ofstream ofs((outPrefix + "script.txt").c_str(),
                    ios_base::binary);
      
      dumpRegion(ifs, ofs, tablestd, 0, numRegion0Strings);
      dumpRegion(ifs, ofs, tablestd, 1, numRegion1Strings);
      dumpRegion(ifs, ofs, tablestd, 2, numRegion2Strings);
      dumpRegion(ifs, ofs, tablestd, 3, numRegion3Strings);
      dumpRegion(ifs, ofs, tablestd, 4, numRegion4Strings);
      dumpRegion(ifs, ofs, tablestd, 5, numRegion5Strings);
      dumpRegion(ifs, ofs, tablestd, 6, numRegion6Strings);
      dumpRegion(ifs, ofs, tablestd, 7, numRegion7Strings);
      dumpRegion(ifs, ofs, tablestd, 8, numRegion8Strings);
      dumpRegion(ifs, ofs, tablestd, 9, numRegion9Strings);
      dumpRegion(ifs, ofs, tablestd, 10, numRegion10Strings);
    }
    
//    dumpString(ifs, ofs, tablestd, 0x1A8D1, 2);
    
    {
      std::ofstream ofs((outPrefix + "script_cutscenes.txt").c_str(),
                    ios_base::binary);
      dumpPointerTable(ifs, ofs, tablestd, 0x1B162, 2, 0xA8);
    }
    
    {
      std::ofstream ofs((outPrefix + "script_shop.txt").c_str(),
                    ios_base::binary);
      
      ifs.seek(0x25BB7);
      for (int i = 0; i < 12; i++) {
        dumpString(ifs, ofs, tablestd, ifs.tell(), 2, 7);
      }
      
      // money counter on main menu -- needs special handling
//      dumpString(ifs, ofs, tablestd, 0x25E20, 2, 7);
    }
  }
  catch (BlackT::TGenericException& e) {
    std::cerr << "Exception: " << e.problem() << std::endl;
    return 1;
  }
  
  
  return 0;
} 

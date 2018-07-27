#! /bin/sh

rm -rvf cscope.* tags

find . -name "*.C" -o -name "*.H" -o -name "*.c" -o -name "*.cpp" -o -name "*.CPP" -o -name "*.cxx" -o -name "*.h" -o -name "*.cc" -o -name "*.S" -o -name "*.s" > ./cscope.files
find .  \( \( -not -type l \) -and \( -iname "*.[chs]" -o -iname "*.cpp" -o -iname "*.cxx" -o -name "*.cc" \) \) > ./files.list

cat ./files.list					 \
 | grep -v ".\/arch\/alpha/"         \
 | grep -v ".\/arch\/arc/"           \
 | grep -v ".\/arch\/avr32/"         \
 | grep -v ".\/arch\/blackfin/"      \
 | grep -v ".\/arch\/c6x/"           \
 | grep -v ".\/arch\/cris/"          \
 | grep -v ".\/arch\/frv/"           \
 | grep -v ".\/arch\/h8300/"         \
 | grep -v ".\/arch\/hexagon/"       \
 | grep -v ".\/arch\/ia64/"          \
 | grep -v ".\/arch\/m32r/"          \
 | grep -v ".\/arch\/m68k/"          \
 | grep -v ".\/arch\/metag/"         \
 | grep -v ".\/arch\/microblaze/"    \
 | grep -v ".\/arch\/mips/"          \
 | grep -v ".\/arch\/mn10300/"       \
 | grep -v ".\/arch\/nios2/"         \
 | grep -v ".\/arch\/openrisc/"      \
 | grep -v ".\/arch\/parisc/"        \
 | grep -v ".\/arch\/powerpc/"       \
 | grep -v ".\/arch\/s390/"          \
 | grep -v ".\/arch\/score/"         \
 | grep -v ".\/arch\/sh/"            \
 | grep -v ".\/arch\/sparc/"         \
 | grep -v ".\/arch\/tile/"          \
 | grep -v ".\/arch\/um/"            \
 | grep -v ".\/arch\/unicore32/"     \
 | grep -v ".\/arch\/x86/"			 \
 | grep -v ".\/arch\/xtensa/" > cscope.files

#cscope -vbkq -i cscope.files
#ctags -R --verbose=yes
cscope -vbk -i cscope.files
ctags --verbose=yes -L cscope.files

rm -rf files.list


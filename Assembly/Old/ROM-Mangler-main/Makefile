# This Makefile will build the MinGW Win32 application on Linux

HEADERS = include/callbacks.h include/resource.h
OBJS =	obj/winmain.o obj/callbacks.o obj/resource.o
INCLUDE_DIRS = -I./include

WARNS = -Wall

CCPREFIX = i686-w64-mingw32-

CC = $(CCPREFIX)gcc
LDFLAGS = -s  -lcrtdll -lcomctl32 -lcomdlg32 -Wl,--subsystem,windows
RC = $(CCPREFIX)windres

# Compile ANSI build only if CHARSET=ANSI
ifeq (${CHARSET}, ANSI)
  CFLAGS = -O3 -std=c99 -D _WIN32_IE=0x0500 -D WINVER=0x500 ${WARNS}
else
  CFLAGS = -O3 -std=c99 -D _WIN32_IE=0x0500 -D WINVER=0x500 ${WARNS}
endif


all: ROM\ Mangler.exe

ROM\ Mangler.exe: ${OBJS}
	${CC} -o "$@" ${OBJS} ${LDFLAGS}

clean:
	rm obj/*.o "ROM Mangler.exe"

obj:
	mkdir obj

obj/%.o: src/%.c ${HEADERS} obj
	${CC} ${CFLAGS} ${INCLUDE_DIRS} -c $< -o $@

obj/resource.o: res/resource.rc res/Application.manifest res/Application.ico include/resource.h
	${RC} -I./include -I./res -i $< -o $@

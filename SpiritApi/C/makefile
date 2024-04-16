GCC=gcc

include_dir=include
src_dir=src
build_out=build

CFLAGS=-I$(include_dir)

headers=$(wildcard $(include_dir)/*.h)
sources=$(wildcard $(src_dir)/*.c)
objects=$(addprefix $(build_out)/,$(notdir $(sources:.c=.o)))

exe_out=$(build_out)/spirit-agent

.PHONY: spirit-agent clean

all: spirit-agent

spirit-agent: $(exe_out)

clean:
	rm -f $(objects) $(exe_out)

$(build_out)/%.o: $(src_dir)/%.c $(headers)
	$(GCC) -c $< -o $@ $(CFLAGS)

$(exe_out): $(headers) $(objects)
	$(GCC) -o $@ $(objects) $(CFLAGS)

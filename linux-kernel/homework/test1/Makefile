#obj-m += producer.o
#obj-m += consumer.o
obj-m += run.o
obj-m += run1.o
#obj-m += force.o

#KBUILD_EXTRA_SYMBOLS=Module.symvers

all:
	make -C /lib/modules/$(shell uname -r)/build M=$(PWD) modules

clean:
	make -C /lib/modules/$(shell uname -r)/build M=$(PWD) clean

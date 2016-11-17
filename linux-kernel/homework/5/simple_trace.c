#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include <fcntl.h>

#define MAX_PATH 256
#define _STR(x) #x
#define STR(x) _STR(x)
static const char *find_debugfs(void){
	static char debugfs[MAX_PATH+1];
	static int debugfs_found;
	char type[100];
	FILE *fp;

	if (debugfs_found)
		return debugfs;

	if ((fp = fopen("/proc/mounts","r")) == NULL)
	    return NULL;

	while (fscanf(fp, "%*s %"
		  STR(MAX_PATH)
		  "s %99s %*s %*d %*d\n",
		  debugfs, type) == 2) {
	    if (strcmp(type, "debugfs") == 0)
		    break;
    }
    fclose(fp);

    if (strcmp(type, "debugfs") != 0)
	    return NULL;

    debugfs_found = 1;

    return debugfs;
}

int trace_fd = -1;
int marker_fd = -1;

int test(){
    struct timespec req;
    req.tv_sec = 0;
    req.tv_nsec = 1000;
    write(marker_fd, "before nano\n", 12);
    nanosleep(&req, NULL);
    write(marker_fd, "after nano\n", 11);
    write(trace_fd, "0", 1);
    return 0;
}

int main(int argc, char *argv){
	const char *debugfs;
	char path[256];

	debugfs = find_debugfs();
	if (debugfs) {
	    strcpy(path, debugfs);
	    strcat(path,"/tracing/tracing_on");
	    trace_fd = open(path, O_WRONLY);
	    if (trace_fd >= 0)
		    write(trace_fd, "1", 1);

	    strcpy(path, debugfs);
	    strcat(path,"/tracing/trace_marker");
	    marker_fd = open(path, O_WRONLY);
	}

    	if (marker_fd >= 0)
	    	write(marker_fd, "In critical area\n", 17);

    	if (test() < 0) {
	    	/* we failed! */
	    	if (trace_fd >= 0)
		    	write(trace_fd, "0", 1);
	 }
}

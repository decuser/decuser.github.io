# itoc
[Main](knr.md)

Well, will wonders never cease, I learned something new today - the compiler doesn't warn you if you put an int into a character and it overflows. I figure this is handy, but mysterious.

```
vi itoc.c

#include <stdio.h>
#include <stdlib.h>

int main(int argc, char* argv[])
{
        int i;
        char c;

        if(argc < 2)
        {
                fprintf(stderr, "Usage: a.out integer\n");
                return 127;
        }

        i = atoi(argv[1]);
        c = i;
        printf("c = %d\n", c);
        
        return 0;
}

cc -Wall --ansi --pedantic -g itoc.c

./a.out
Usage: a.out integer
./a.out 1
c = 1
./a.out 127
c = 127
./a.out 128
c = -128
./a.out 97348234
c = -118
```

What I don't understand is why it doesn't cause the overflow flag to be set.

```
lldb a.out
(lldb) target create "a.out"
Current executable set to 'a.out' (x86_64).
(lldb) list -
   1   	#include <stdio.h>
   2   	#include <stdlib.h>
   3   	
   4   	int main(int argc, char* argv[])
   5   	{
   6   		int i;
   7   		char c;
   8   	
   9   		if(argc < 2)
   10  		{
(lldb) list
   11  			fprintf(stderr, "Usage: a.out integer\n");
   12  			return 127;
   13  		}
   14  	
   15  		i = atoi(argv[1]);
   16  		c = i;
   17  		printf("c = %d\n", c);
   18  	
   19  		return 0;
   20  	}
(lldb) breakpoint set --line 16
Breakpoint 1: where = a.out`main + 94 at itoc.c:16, address = 0x0000000100000f2e
(lldb) run
Process 29535 launched: '/Users/wsenn/sandboxes/cprog/knr/a.out' (x86_64)
Usage: a.out integer
Process 29535 exited with status = 127 (0x0000007f) 
(lldb) run 1
Process 29548 launched: '/Users/wsenn/sandboxes/cprog/knr/a.out' (x86_64)
Process 29548 stopped
* thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 1.1
    frame #0: 0x0000000100000f2e a.out`main(argc=2, argv=0x00007ffeefbff958) at itoc.c:16
   13  		}
   14  	
   15  		i = atoi(argv[1]);
-> 16  		c = i;
   17  		printf("c = %d\n", c);
   18  	
   19  		return 0;
Target 0: (a.out) stopped.
(lldb) print i
(int) $0 = 1
(lldb) register read rflags --format binary
  rflags = 0b0000000000000000000000000000000000000000000000000000001000000110
(lldb) step
Process 29548 stopped
* thread #1, queue = 'com.apple.main-thread', stop reason = step in
    frame #0: 0x0000000100000f36 a.out`main(argc=2, argv=0x00007ffeefbff958) at itoc.c:17
   14  	
   15  		i = atoi(argv[1]);
   16  		c = i;
-> 17  		printf("c = %d\n", c);
   18  	
   19  		return 0;
   20  	}
Target 0: (a.out) stopped.
(lldb) register read rflags --format binary
  rflags = 0b0000000000000000000000000000000000000000000000000000001000000110
(lldb) kill
Process 29548 exited with status = 9 (0x00000009) 
(lldb) r
Process 29865 launched: '/Users/wsenn/sandboxes/cprog/knr/a.out' (x86_64)
Process 29865 stopped
* thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 1.1
    frame #0: 0x0000000100000f2e a.out`main(argc=2, argv=0x00007ffeefbff958) at itoc.c:16
   13  		}
   14  	
   15  		i = atoi(argv[1]);
-> 16  		c = i;
   17  		printf("c = %d\n", c);
   18  	
   19  		return 0;
Target 0: (a.out) stopped.
(lldb) print i
(int) $1 = 1
(lldb) expr i = 128
(int) $2 = 128
(lldb) register read rflags --format binary
  rflags = 0b0000000000000000000000000000000000000000000000000000001000000110
(lldb) step
Process 29865 stopped
* thread #1, queue = 'com.apple.main-thread', stop reason = step in
    frame #0: 0x0000000100000f36 a.out`main(argc=2, argv=0x00007ffeefbff958) at itoc.c:17
   14  	
   15  		i = atoi(argv[1]);
   16  		c = i;
-> 17  		printf("c = %d\n", c);
   18  	
   19  		return 0;
   20  	}
Target 0: (a.out) stopped.
(lldb) register read rflags --format binary
  rflags = 0b0000000000000000000000000000000000000000000000000000001000000110
(lldb) kill
Process 29865 exited with status = 9 (0x00000009) 
(lldb) r 655536
Process 30012 launched: '/Users/wsenn/sandboxes/cprog/knr/a.out' (x86_64)
Process 30012 stopped
* thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 1.1
    frame #0: 0x0000000100000f2e a.out`main(argc=2, argv=0x00007ffeefbff950) at itoc.c:16
   13  		}
   14  	
   15  		i = atoi(argv[1]);
-> 16  		c = i;
   17  		printf("c = %d\n", c);
   18  	
   19  		return 0;
Target 0: (a.out) stopped.
(lldb) print i
(int) $3 = 655536
(lldb) register read rflags --format binary
  rflags = 0b0000000000000000000000000000000000000000000000000000001000000110
(lldb) step
Process 30012 stopped
* thread #1, queue = 'com.apple.main-thread', stop reason = step in
    frame #0: 0x0000000100000f36 a.out`main(argc=2, argv=0x00007ffeefbff950) at itoc.c:17
   14  	
   15  		i = atoi(argv[1]);
   16  		c = i;
-> 17  		printf("c = %d\n", c);
   18  	
   19  		return 0;
   20  	}
Target 0: (a.out) stopped.
(lldb) register read rflags --format binary
  rflags = 0b0000000000000000000000000000000000000000000000000000001000000110
(lldb) kill
Process 30012 exited with status = 9 (0x00000009) 
(lldb) r 2147483647
Process 30182 launched: '/Users/wsenn/sandboxes/cprog/knr/a.out' (x86_64)
Process 30182 stopped
* thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 1.1
    frame #0: 0x0000000100000f2e a.out`main(argc=2, argv=0x00007ffeefbff950) at itoc.c:16
   13  		}
   14  	
   15  		i = atoi(argv[1]);
-> 16  		c = i;
   17  		printf("c = %d\n", c);
   18  	
   19  		return 0;
Target 0: (a.out) stopped.
(lldb) print i
(int) $4 = 2147483647
(lldb) register read rflags --format binary
  rflags = 0b0000000000000000000000000000000000000000000000000000001000000110
(lldb) step
Process 30182 stopped
* thread #1, queue = 'com.apple.main-thread', stop reason = step in
    frame #0: 0x0000000100000f36 a.out`main(argc=2, argv=0x00007ffeefbff950) at itoc.c:17
   14  	
   15  		i = atoi(argv[1]);
   16  		c = i;
-> 17  		printf("c = %d\n", c);
   18  	
   19  		return 0;
   20  	}
Target 0: (a.out) stopped.
(lldb) register read rflags --format binary
  rflags = 0b0000000000000000000000000000000000000000000000000000001000000110
(lldb) kill
Process 30182 exited with status = 9 (0x00000009) 
(lldb) run 2147483648
Process 30225 launched: '/Users/wsenn/sandboxes/cprog/knr/a.out' (x86_64)
Process 30225 stopped
* thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 1.1
    frame #0: 0x0000000100000f2e a.out`main(argc=2, argv=0x00007ffeefbff950) at itoc.c:16
   13  		}
   14  	
   15  		i = atoi(argv[1]);
-> 16  		c = i;
   17  		printf("c = %d\n", c);
   18  	
   19  		return 0;
Target 0: (a.out) stopped.
(lldb) print i
(int) $5 = -2147483648
(lldb) register read rflags --format binary
  rflags = 0b0000000000000000000000000000000000000000000000000000001000000110
(lldb) step
Process 30225 stopped
* thread #1, queue = 'com.apple.main-thread', stop reason = step in
    frame #0: 0x0000000100000f36 a.out`main(argc=2, argv=0x00007ffeefbff950) at itoc.c:17
   14  	
   15  		i = atoi(argv[1]);
   16  		c = i;
-> 17  		printf("c = %d\n", c);
   18  	
   19  		return 0;
   20  	}
Target 0: (a.out) stopped.
(lldb) register read rflags --format binary
  rflags = 0b0000000000000000000000000000000000000000000000000000001000000110
(lldb) print c
(char) $6 = '\0'
(lldb) print i
(int) $7 = -2147483648
(lldb) step
c = 0
Process 30225 stopped
* thread #1, queue = 'com.apple.main-thread', stop reason = step in
    frame #0: 0x0000000100000f41 a.out`main(argc=2, argv=0x00007ffeefbff950) at itoc.c:19
   16  		c = i;
   17  		printf("c = %d\n", c);
   18  	
-> 19  		return 0;
   20  	}
   21  	
Target 0: (a.out) stopped.
(lldb) c
Process 30225 resuming
Process 30225 exited with status = 0 (0x00000000) 
(lldb) q

```

Well, I'm sure there's a good reason waiting to be found :)

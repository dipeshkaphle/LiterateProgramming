# Literate Programming Tutorial

Hi I'm Dipesh
This is a tool I made to get the code out of Markdown files

This is one block of code of C language
```c
#include <stdio.h>

```
I can have many language blocks inside this file

But It will only take the language blocks of the language in the extenstion before .md in the markdown file.

For example: Lets say you have a file "abc.c.md", so this will only get the "c" codeblocks  from this file and stick them together.

This will be ignored
```python
print("Hello World")
```

This will be taken

```c
int main(){
  printf("Hello from Markdown\n");
}
```

I guess that's it.

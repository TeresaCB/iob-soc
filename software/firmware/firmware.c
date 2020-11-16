//#include "stdlib.h"
//#include "stdio.h"
#include "system.h"
#include "periphs.h"
#include "iob-uart.h"

int main()
{
  //init uart 
  uart_init(UART_BASE,FREQ/BAUD);   
  uart_printf("\n\n\nHello world!\n\n\n");
  //char *a = malloc(10);
  //free(a);
  
  unsigned long long int fib[100] = {0};
  
  /*fib = (int*)malloc(100*sizeof(int));
  if (fib == NULL) { 
        uart_printf("\nMemory not allocated.\n"); 
        exit(0); 
  } */

  fib[0]=0;
  fib[1]=1;
  
  uart_printf("\n\n Fibonnaci element 0 : %d \n", fib[0]);
  uart_printf("\n\n Fibonnaci element 0 : %d \n", fib[1]);
  
  for(int i=2; i<100; i++){
  	fib[i] = fib[i-1]+fib[i-2]; 
  	uart_printf("\n\n Fibonnaci element %d : %d \n", i, fib[i]);
  }
  
  //free(fib);
  
  return 0;
  
}

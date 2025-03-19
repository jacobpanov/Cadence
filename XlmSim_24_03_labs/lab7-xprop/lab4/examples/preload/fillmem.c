#include <stdio.h>

void main()
{
  printf("\n This program dumps the memory files\n");

  int i,j;
  FILE *fp1, *fp2, *fp2a, *fp3;
  char infile1[128],infile2[128],infile2a[128],infile3[128];
  int conv[32], conv1[32], remainder,tmp_data, tmp_data1;

  strcpy(infile1,"extmem.txt");
  if((fp1 = fopen(infile1,"w+")) == NULL)
  {
	 printf("unable to open file %s\n",infile1);
	 exit(0);
  }
  strcpy(infile2,"readable_datamem.txt");
  if((fp2 = fopen(infile2,"w+")) == NULL)
  {
	 printf("unable to open file %s\n",infile2);
	 exit(0);
  }
  strcpy(infile2a,"datamem.txt");
  if((fp2a = fopen(infile2a,"w+")) == NULL)
  {
	 printf("unable to open file %s\n",infile2a);
	 exit(0);
  }
  strcpy(infile3,"tagmem.txt");
  if((fp3 = fopen(infile3,"w+")) == NULL)
  {
	 printf("unable to open file %s\n",infile3);
	 exit(0);
  }
  
  /* Address and data dumping */
  for(i=0;i<8*65536;i++)
  {
     /* address conversion to 32bit*/
     tmp_data = i;
     tmp_data1 = i;
     //for(j=0;j<32;j++)
     //{
	 //  conv[31-j] = tmp_data%2;
     //  tmp_data = tmp_data >> 1;
	 //}  
     //for(j=0;j<32;j++)
     //{
	 //  conv1[31-j] = tmp_data1%2;
     //  tmp_data1 = tmp_data1 >> 1;
	 //}  
     /* 32-bit address for memory*/
     for(j=0;j<32;j++)
     {
        //fprintf(fp1,"%d",conv[j]);
	 }	
     //fprintf(fp1," ");

     /* 16-bit address for tag and data memory only 65536 location*/
	 if((i==0) || ((i)%4==0))
	 {
	   for(j=14;j<30;j++)
       {
          //fprintf(fp2,"%d",conv[j]);
          //fprintf(fp2a,"%d",conv[j]);
          //fprintf(fp3,"%d",conv[j]);
	   }	
       //fprintf(fp2," ");
       //fprintf(fp2a," ");
       //fprintf(fp3," ");
	 }  
	 
	 /* data dumping for external memory*/
	 if (i%4 == 0){ tmp_data = i+3;}
	 else
	 if (i%4 == 1){ tmp_data = i+1;}
	 else
	 if (i%4 == 2){ tmp_data = i-1;}
	 else
	 if (i%4 == 3){ tmp_data = i-3;}
     for(j=0;j<32;j++)
     {
	   conv[31-j] = tmp_data%2;
       tmp_data = tmp_data >> 1;
	 }  
     for(j=0;j<32;j++)
     {
	   conv1[31-j] = tmp_data1%2;
       tmp_data1 = tmp_data1 >> 1;
	 }  
     for(j=0;j<32;j++)
     {
        fprintf(fp1,"%d",conv1[j]);
	 }	
     fprintf(fp1,"\n");
	 
	 /* data dumping for data memory*/
	 if(i<4*65536)
	 {
       if((i==0))
	   {
         fprintf(fp2,"0");  /* this is the dirty bit storage */
         fprintf(fp2a,"0");  /* this is the dirty bit storage */
	   }
	   for(j=0;j<32;j++)
       {
          fprintf(fp2,"%d",conv[j]);
          fprintf(fp2a,"%d",conv[j]);
	   }	
       if((i!=0) && (i-3)%4==0)
	   {
         //  fprintf(fp2,"0");  /* this is the dirty bit storage */
         //  fprintf(fp2a,"0");  /* this is the dirty bit storage */
         fprintf(fp2,"\n");
         fprintf(fp2a,"\n");
	     if(i<4*65535)
	     {
           fprintf(fp2,"0");  /* this is the dirty bit storage */
           fprintf(fp2a,"0");  /* this is the dirty bit storage */
	     }	 
	   }
	   else
	   {
         fprintf(fp2,"_");
         fprintf(fp2a,"_");  
	   }
       /* 14-bit address as data for tag memory only 65536 location*/
	   if((i==0) || ((i)%4==0))
	   {
	     for(j=0;j<13;j++)
         {
            fprintf(fp3,"%d",conv[j]);
	     }	
         fprintf(fp3,"\n");
	   }  
	 } 
  }	 
  fclose(fp1);
  fclose(fp2);
  fclose(fp2a);
  fclose(fp3);
}

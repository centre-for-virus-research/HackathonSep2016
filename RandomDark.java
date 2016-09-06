package randomdark;

import java.io.*;
import java.util.Random;

public class RandomDark {

    public static double baseProbs[]=new double[5];
    
    public static void main(String[] args) {
        
        System.out.println("RandomDark.jar started - randomly generate FASTQ reads");
        
        Random ranGen=new Random();
        double ran=0;
        int readLength=250, readNum=10000000;
        String stub="output", file1="output_1.fastq", file2="output_2.fastq";
        
        char bases[]=new char[5];
        bases[0]='A';
        bases[1]='C';
        bases[2]='G';
        bases[3]='T';
        bases[4]='N';

        defaultProbs();

        if(args.length==3 | args.length==8) {
            readNum=Integer.parseInt(args[0]);
            readLength=Integer.parseInt(args[1]);

            stub=args[2];
            
            if(args.length==8){
                baseProbs[0]=Double.parseDouble(args[3]);
                baseProbs[1]=Double.parseDouble(args[4]);
                baseProbs[2]=Double.parseDouble(args[5]);
                baseProbs[3]=Double.parseDouble(args[6]);
                baseProbs[4]=Double.parseDouble(args[7]);

                double sum=0;
                for(int i=0;i<baseProbs.length;i++) {
                    sum+=baseProbs[i];
                }
                if(sum>1) {
                    System.out.println("\n***Error - base probalities sum to greater than 1 - reverting to defaults\n");
                    defaultProbs();
                }
                if(sum<1) {
                    System.out.println("\n***Error - base probalities sum to less than 1 - reverting to defaults\n");
                    defaultProbs();
                }
            }
        }

        else {
            System.out.println("\n***Error - Incorrect usage: "+args.length+" arguments were given - expected 3 or 8");
            System.out.println("Correct usage [standard]: java -jar RandomDark.jar NumberOfReads[int] ReadLength[int] OutputFilenameStub[string]");
            System.out.println("Correct usage [extended]: java -jar RandomDark.jar NumberOfReads[int] ReadLength[int] OutputFilenameStub[string] Aprob[double] Cprob[double] Gprob[double] Tprob[double] Nprob[double]\n");
            System.out.println("Program will create files: OutputFilenameStub_1.fastq OutputFilenameStub_2.fastq");
            System.exit(0);
        }

        file1=stub+"_1.fastq";
        file2=stub+"_2.fastq";
        
        //Outputting all settings to the terminal           
        System.out.println("Simulated Number of Reads = "+readNum);
        System.out.println("Simulated Length of Reads = "+readLength);

        System.out.println("Output 1st Pair filename  = "+file1);
        System.out.println("Output 2nd Pair filename  = "+file2);
  
        System.out.println("A probability = "+baseProbs[0]);
        System.out.println("C probability = "+baseProbs[1]);
        System.out.println("G probability = "+baseProbs[2]);
        System.out.println("T probability = "+baseProbs[3]);
        System.out.println("N probability = "+baseProbs[4]);

        
        //Generate cumulative probabilities
        double cumProbs[]=new double[5];
        for(int i=0;i<baseProbs.length;i++) {
            cumProbs[i]=baseProbs[i];

            if(i>0)
                cumProbs[i]+=cumProbs[i-1];

            //System.out.println(bases[i]+" "+baseProbs[i]+" "+cumProbs[i]);
            
            if(cumProbs[i]>1) {
                System.out.println("Rounding error? base = "+bases[i]+" "+cumProbs[i]+" greater than 1, rounding down to 1");
                cumProbs[i]=1;
            }
        }
        
        //Output Sequence Files
        String outFilename="";
        
        for(int p=0;p<2;p++) {
            try{
                if(p==0)
                    outFilename=file1;
                else
                    outFilename=file2;
                
                System.out.println("Outputting file "+outFilename);
                
                FileWriter fstream = new FileWriter(outFilename);
                BufferedWriter out = new BufferedWriter(fstream);

                for(int i=0;i<readNum;i++) {
                    
                    if((i+1)%1000000==0)
                        System.out.println("Out ReadNum "+(i+1));
                    
                    out.write("@SimReadNumber"+(i+1)+"_"+(p+1)+"\n");

                    //Read Seqeunce
                    for(int j=0;j<readLength;j++) {
                        ran=ranGen.nextDouble();

                        int sel=0;
                        for(int k=0;k<cumProbs.length;k++) {
                            sel=k;

                            if(ran<=cumProbs[k]) {
                                break;
                            }
                        }

                        out.write(bases[sel]);
                    }

                    out.write("\n");
                            
                    //Quality Scores
                    out.write("+\n");

                    for(int j=0;j<readLength;j++) {
                        out.write("I");
                    }

                    out.write("\n");
                    
                }

                out.close();
            }

            catch (Exception e) {
                System.err.println("Error: " + e.getMessage());
            }
        }
        
        System.out.println("...Finished");
    }
    
    public static void defaultProbs() {
        
        baseProbs[0]=0.25;
        baseProbs[1]=0.25;
        baseProbs[2]=0.25;
        baseProbs[3]=0.25;
        baseProbs[4]=0;
        
    }
    
}

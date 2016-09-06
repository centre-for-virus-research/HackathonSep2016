package randomvirus;

import java.io.*;
import java.util.Random;

public class RandomVirus {

    public static double baseProbs[]=new double[5];
    
    public static void main(String[] args) {
        
        System.out.println("RandomVirus.jar started - randomly generate FASTQ dataset from viral sequences");
        
        Random ranGen=new Random();
        int readNum=10000000, readLength=250, count=0;
        String filename="/Users/rjorton/Downloads/all_virus_seq_new.fasta", stub="output", file1="output_1.fastq", file2="output_2.fastq";
        boolean eqProb=false;
        
        int insSize=350;

        if(args.length==5) {
            filename=args[0];//Relise on FASTA being single line!!!!!
            readNum=Integer.parseInt(args[1]);
            readLength=Integer.parseInt(args[2]);
            
            if(args[3].equalsIgnoreCase("y"))
                eqProb=true;
            else if(args[3].equalsIgnoreCase("n"))
                eqProb=false;
            else {
                System.out.println("\n***Error - Unrecognised EqualProbability argument - "+args[3]+" - setting EqProb to TRUE\n");
                eqProb=true;
            }
            
            stub=args[4];
        }
        else {
            System.out.println("\n***Error - Incorrect usage: "+args.length+" arguments were given - expected 5");
            System.out.println("Correct usage: java -jar RandomVirus.jar InputSequenFileName[string] NumberOfReads[int] ReadLength[int] EqualProbability[y/n] OutputFilenameStub[string]");
            System.exit(0);
        }
        
        file1=stub+"_1.fastq";
        file2=stub+"_2.fastq";
        
        System.out.println("Input sequence file = "+filename);
        System.out.println("Number of reads to output = "+readNum);
        System.out.println("Read Length = "+readLength);
        
        if(eqProb)
            System.out.println("Using equal probability for viruses");
        else
            System.out.println("Scaling probability by virus length");
        
        System.out.println("Output 1st Pair filename  = "+file1);
        System.out.println("Output 2nd Pair filename  = "+file2);
 
        try {
            BufferedReader input =  new BufferedReader(new FileReader(filename));

            try {
                String line = null;

                while (( line = input.readLine()) != null) {
                    if(line.charAt(0)=='>') {
                        count++;
                    }
                }
            }
            finally {
                input.close();
            }
        }
        catch (IOException ex) {
            ex.printStackTrace();
        }
        
        System.out.println("Total sequences in file = "+count);
        
        String vAccs[]=new String[count];//virus seq accessions
        String vNames[]=new String[count];//virus seq desc
        int vLengths[]=new int[count];//virus seq lengths
        double vProbs[]=new double[count];//probability of random selection
        int vCounts[]=new int[count];//number of reads to output from each virus

        count=-1;
        try {
            BufferedReader input =  new BufferedReader(new FileReader(filename));

            try {
                String line = null;

                while (( line = input.readLine()) != null) {
                    if(line.charAt(0)=='>') {
                        count++;
                        String splits[]=line.split("\\|");
                        vAccs[count]=splits[3];
                        vNames[count]=splits[4];
                    }
                    else {
                        vLengths[count]+=line.length();
                    }
                }
            }
            finally {
                input.close();
            }
        }
        catch (IOException ex) {
            ex.printStackTrace();
        }
        
        double totLen=0;
        for(int i=0;i<vLengths.length;i++) {
            //if(vLengths[i]<readLength*2+insSize)
            if(vLengths[i]<readLength)
                System.out.println("Warning: "+vAccs[i]+" "+vNames[i]+" small seq "+vLengths[i]);
            
            totLen+=vLengths[i];
        }
        System.out.println("Total sequence length = "+totLen);

        System.out.println("Determining probabilities of sequencing");
        for(int i=0;i<vProbs.length;i++) {
            if(eqProb)
                vProbs[i]=(double)1/(double)vProbs.length;
            else
                vProbs[i]=(double)vLengths[i]/totLen;
            
            if(i>0)
                vProbs[i]+=vProbs[i-1];
            
            if(vProbs[i]>1) {
                System.out.println("Rounding error? base = "+i+" "+vAccs[i]+" greater than 1, rounding down to 1");
                vProbs[i]=1;
            }
        }
        
        System.out.println("Determining number of reads per sequence");
        int sel=0;
        double ran=0;
        for(int i=0;i<readNum;i++) {
            sel=0;
            
            if(eqProb)
                sel=ranGen.nextInt(vProbs.length);
            else {
                ran=ranGen.nextDouble();
                
                for(int j=0;j<vProbs.length;j++) {
                    if(ran<=vProbs[j]) {
                        sel=j;
                        break;
                    }
                }
            }
            vCounts[sel]++;
        }
        
        //Output the reads
        try{
                
            FileWriter fstream = new FileWriter(file1);
            BufferedWriter out = new BufferedWriter(fstream);

            FileWriter fstream2 = new FileWriter(file2);
            BufferedWriter out2 = new BufferedWriter(fstream2);

            try {
                BufferedReader input =  new BufferedReader(new FileReader(filename));

                try {
                    String line = null, seq="";
                    int start=0, end=0, rCount=0;
                    count=-1;

                    while (( line = input.readLine()) != null) {
                        if(line.charAt(0)=='>') {
                            count++;
                        }
                        else {
                            if(vCounts[count]>0) {
                                System.out.println("Virus: "+vAccs[count]+" "+vNames[count]+" Length="+vLengths[count]+" Reads="+vCounts[count]);
                                seq=line;   
                                
                                for(int i=0;i<vCounts[count];i++) {
                                    rCount++;
                                    out.write("@Seq"+vAccs[count]+"-"+rCount+"_1\n");
                                    out2.write("@Seq"+vAccs[count]+"-"+rCount+"_2\n");

                                    int lim=vLengths[count]-readLength*2-insSize;
                                    if(lim<=0) lim=1;

                                    start=ranGen.nextInt(lim);
                                    end=start+readLength;

                                    if(end>vLengths[count])
                                        end=vLengths[count];

                                    out.write(seq.substring(start, end)+"\n+\n");
                                    for(int j=0;j<(end-start);j++)
                                        out.write("I");
                                    out.write("\n");

                                    start+=readLength+insSize;
                                    if(start>vLengths[count]-readLength)
                                        start=vLengths[count]-readLength;
                                    if(start<0)
                                        start=0;

                                    end=start+readLength;
                                    if(end>vLengths[count])
                                        end=vLengths[count];

                                    
                                    String rev=new StringBuffer(seq.substring(start, end)).reverse().toString();
                                    String seq2="";
                                    for(int j=0;j<rev.length();j++) {
                                        if(rev.charAt(j)=='A')
                                           seq2+="T";
                                        else if(rev.charAt(j)=='C')
                                           seq2+="G";
                                        else if(rev.charAt(j)=='G')
                                           seq2+="C";
                                        else if(rev.charAt(j)=='T')
                                           seq2+="A";
                                        else
                                           seq2+="N";
                                    }
                                    
                                    out2.write(seq2+"\n+\n");
                                    for(int j=0;j<seq2.length();j++)
                                        out2.write("I");
                                    out2.write("\n");            
                                }
                            }
                        }                  
                    }
                }
                finally {
                    input.close();
                }
            }
            catch (IOException ex) {
                ex.printStackTrace();
            }

            out.close();
            out2.close();
        }

        catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
        }

        System.out.println("...Finished");
    }

}

import struct
import torch
from argparse import ArgumentParser

parser = ArgumentParser()
parser.add_argument('--mode', '-m', type=int, required=True)
mode = parser.parse_args().mode

# mode0 ---- two inputs
# mode1 ---- three inputs
# mode2 ---- four inputs
# mode3 ---- six inputs  

def hex_to_bfloat(hex_string):
    # 将十六进制字符串转换为二进制字符串
    binary_string = bin(int(hex_string, 16))[2:].zfill(16)
    # print(hex_string)
    # print(binary_string)
    # 将二进制字符串转换为bfloat16
    sign = int(binary_string[0],2)
    exponent = int(binary_string[1:9],2)
    mantissa = int(binary_string[9:16],2)
    # print(sign)
    # print(exponent) 
    # print(mantissa)
    # set zero and subnormal to zero
    if exponent == 0:
        bfloat16 = torch.tensor(0).to(torch.bfloat16)
    else:
        # convert to float
        f = (-1)**sign * 2**(exponent-127) * (1+mantissa/2**7)
        # convert to bfloat16
        bfloat16 = torch.tensor(f).to(torch.bfloat16)
    return bfloat16

def bfloat_to_hex(f):
    if f < 1e-126 and f > -1e-126:
        return "0000"
    # 使用struct模块将浮点数转换为二进制表示
    b = struct.pack('!f', f)
    
    # 将二进制数据转换为十六进制字符串
    hex_string = ''.join(format(byte, '02x') for byte in b)
    bfloat_hex_string = hex_string[0:4]
    return bfloat_hex_string

    

if __name__ == "__main__":

    # modify this variable to change the mode
    # mode0 ---- two inputs
    # mode1 ---- three inputs
    # mode2 ---- four inputs
    # mode3 ---- six inputs 

    error = 0
    if_nan = 0


    input_path = 'stim_inputs.txt'
    if mode == 0:
        hardware_output_path = 'stim_outputs_mode0.txt'
    elif mode == 1:
        hardware_output_path = 'stim_outputs_mode1.txt'
    elif mode == 2:
        hardware_output_path = 'stim_outputs_mode2.txt'
    elif mode == 3:
        hardware_output_path = 'stim_outputs_mode3.txt'

    # 逐行读取十六进制数
    with open(input_path, 'r') as input_file:
        with open(hardware_output_path, 'r') as output_file:
            hex_inputs = input_file.readline().strip()
            hardware_outputs = output_file.readline().strip()
            while hex_inputs:
                print(hex_inputs)
                bfloat_inputs = [0, 0, 0, 0, 0, 0, 0, 0]
                soft_results = [0, 0, 0, 0]
                hard_results = [0, 0, 0, 0]
                middle = [0, 0, 0, 0, 0]
                # 将十六进制数转换为BF16
                for i in range (8):
                    bfloat_inputs[i] = hex_to_bfloat(hex_inputs[i*4:i*4+4])
                    # 如果bfloat_inputs为subnormal数，将其转换为0
                    if bfloat_inputs[i] < 1e-126 and bfloat_inputs[i] > -1e-126:
                        bfloat_inputs[i] = torch(0)                


                if mode == 0:
                    soft_results[0] = bfloat_inputs[0] * bfloat_inputs[1]
                    soft_results[1] = bfloat_inputs[2] * bfloat_inputs[3]
                    soft_results[2] = bfloat_inputs[4] * bfloat_inputs[5]
                    soft_results[3] = bfloat_inputs[6] * bfloat_inputs[7]
                    for j in range(4):
                        hard_results[j] = hex_to_bfloat(hardware_outputs[j*4:j*4+4])
                        print("soft_results"+str(j)+" "+str(soft_results[j]))
                        print("hard_results"+str(j)+" "+str(hard_results[j]))     
                        if soft_results[j] != hard_results[j]:
                            if(hard_results[j]<1e-37 and hard_results[j]>-1e-37 and soft_results[j]==0):
                                continue
                            elif(soft_results[j]<1e-37 and soft_results[j]>-1e-37 and hard_results[j]==0):
                                continue
                            print("Error!!!!!")
                            error = 1
                             
                        
                elif mode == 1:
                    middle[0] = bfloat_inputs[2] * bfloat_inputs[3]
                    middle[1] = bfloat_inputs[6] * bfloat_inputs[7]
                    for k in range (2):
                        if middle[k] < 2^(-125) and middle[k] > -2^(-125):
                            middle[k] = torch.tensor(0).to(torch.bfloat16) 
                               
                    soft_results[2] = bfloat_inputs[1] * middle[0] 
                    soft_results[3] = bfloat_inputs[5] * middle[1]
                    for j in range(2,4):
                        hard_results[j] = hex_to_bfloat(hardware_outputs[j*4:j*4+4])    
                        print("soft_results"+str(j)+" "+str(soft_results[j]))
                        print("hard_results"+str(j)+" "+str(hard_results[j]))  
                        if soft_results[j] != hard_results[j]:
                            if(hard_results[j]<2^(-125) and hard_results[j]>-2^(-125) and soft_results[j]==0):
                                continue
                            elif(soft_results[j]<2^(-125) and soft_results[j]>-2^(-125) and hard_results[j]==0):
                                continue
                            elif(soft_results[j]>2^126 and hard_results[j]==torch.inf):
                                continue
                            elif(soft_results[j]<-2^126 and hard_results[j]==-torch.inf):
                                continue
                            print("Error!!!!!")
                            error = 1

                elif mode == 2:
                    middle[0] = bfloat_inputs[0] * bfloat_inputs[1]
                    middle[1] = bfloat_inputs[2] * bfloat_inputs[3]
                    middle[2] = bfloat_inputs[4] * bfloat_inputs[5]
                    middle[3] = bfloat_inputs[6] * bfloat_inputs[7]
                    for k in range (4):
                        if middle[k] < 2^(-125) and middle[k] > -2^(-125):
                            middle[k] = torch.tensor(0).to(torch.bfloat16)                     
                               
                    soft_results[2] = middle[0] * middle[1]
                    soft_results[3] = middle[2] * middle[3]
                    for j in range(2,4):
                        hard_results[j] = hex_to_bfloat(hardware_outputs[j*4:j*4+4])    
                        print("soft_results"+str(j)+" "+str(soft_results[j]))
                        print("hard_results"+str(j)+" "+str(hard_results[j]))  
                        if soft_results[j] != hard_results[j]:
                            if(hard_results[j]<2^(-125) and hard_results[j]>-2^(-125) and soft_results[j]==0):
                                continue
                            elif(soft_results[j]<2^(-125) and soft_results[j]>-2^(-125) and hard_results[j]==0):
                                continue
                            elif(soft_results[j]>2^126 and hard_results[j]==torch.inf):
                                continue
                            elif(soft_results[j]<-2^126 and hard_results[j]==-torch.inf):
                                continue
                            print("Error!!!!!")
                            error = 1     

                elif mode == 3:
                    middle[1] = bfloat_inputs[2] * bfloat_inputs[3]
                    middle[2] = bfloat_inputs[4] * bfloat_inputs[5]
                    middle[3] = bfloat_inputs[6] * bfloat_inputs[7]
                    for k in range (1,4):
                        if middle[k] < 2^(-125) and middle[k] > -2^(-125):
                            middle[k] = torch.tensor(0).to(torch.bfloat16)     
                    middle[4] = middle[2] * middle[3]
                    if middle[4] < 2^(-125) and middle[4] > -2^(-125):
                        middle[4] = torch.tensor(0).to(torch.bfloat16)
                    soft_results[3] = middle[1] * middle[4]
                    for j in range(2,4):
                        hard_results[j] = hex_to_bfloat(hardware_outputs[j*4:j*4+4])    
                        print("soft_results"+str(j)+" "+str(soft_results[j]))
                        print("hard_results"+str(j)+" "+str(hard_results[j]))  
                        if soft_results[j] != hard_results[j]:
                            if(hard_results[j]<2^(-125) and hard_results[j]>-2^(-125) and soft_results[j]==0):
                                continue
                            elif(soft_results[j]<2^(-125) and soft_results[j]>-2^(-125) and hard_results[j]==0):
                                continue
                            elif(soft_results[j]>2^126 and hard_results[j]==torch.inf):
                                continue
                            elif(soft_results[j]<-2^126 and hard_results[j]==-torch.inf):
                                continue
                            elif(soft_results[j] == torch.nan):
                                print("NAN!!!")
                                if_nan = 1
                                continue
                            print("Error!!!!!")
                            error = 1                                                      

                hex_inputs = input_file.readline().strip()
                hardware_outputs = output_file.readline().strip()  

    if(error == 0):
        print("Done. All results are correct!")      





    
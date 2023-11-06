import struct
import torch

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

        # mode0 ---- two inputs
        # mode1 ---- three inputs
        # mode2 ---- four inputs
        # mode3 ---- six inputs      

if __name__ == "__main__":

    # modify this variable to change the mode
    mode = 0
    error = 0

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
                        if soft_results[j] < 2**(-125) and soft_results[j] > -2**(-125):
                            soft_results[j] = torch.tensor(0).to(torch.bfloat16)
                        elif soft_results[j] > 2e126:
                            soft_results[j] = torch.inf.to(torch.bfloat16)  
                        elif soft_results[j] < -2e126:
                            soft_results[j] = -torch.inf.to(torch.bfloat16) 
                        hard_results[j] = hex_to_bfloat(hardware_outputs[j*4:j*4+4])
                        print("soft_results"+str(j)+" "+str(soft_results[j]))
                        print("hard_results"+str(j)+" "+str(hard_results[j]))     
                        if soft_results[j] != hard_results[j]:
                            if(hard_results[j]<1e-37 and hard_results[j]>-1e-37 and soft_results[j]==0):
                                continue
                            elif(soft_results[j]<1e-37 and soft_results[j]>-1e-37 and hard_results[j]==0):
                                continue
                            print("Error!")
                            print("soft_results: "+str(soft_results[j]))
                            print("hard_results: "+str(hard_results[j]))
                            error = 1
                             
                        
                elif mode == 1:
                    soft_results[0] = torch(0).to(torch.bfloat16)
                    soft_results[1] = bfloat_inputs[2] * bfloat_inputs[3]
                    soft_results[2] = bfloat_inputs[4] * bfloat_inputs[5]
                    soft_results[3] = bfloat_inputs[6] * bfloat_inputs[7]
                    for j in range(4):
                        if soft_results[j] < 2e-125 and soft_results[j] > -2e-125:
                            soft_results[j] = 0   
                        elif soft_results[j] > 2e126:
                            soft_results[j] = torch.inf.to(torch.bfloat16)  
                        elif soft_results[j] < -2e126:
                            soft_results[j] = -torch.inf.to(torch.bfloat16) 
                        print(soft_results[j])           


                hex_inputs = input_file.readline().strip()
                hardware_outputs = output_file.readline().strip()  

    if(error == 0):
        print("Done. All results are correct!")            
    
    
    
    # # software_output_path和hardware_output_path中的结果逐行比较
    # error = 0
    # with open(software_output_path, 'r') as output_file:
    #     with open(hardware_output_path, 'r') as hardware_output_file:
    #         output_hex = output_file.readline().strip()
    #         hardware_output_hex = hardware_output_file.readline().strip()
    #         while output_hex:
    #             if output_hex != hardware_output_hex:
    #                 print("Error!")
    #                 print("output_hex: "+output_hex)
    #                 print("hardware_output_hex: "+hardware_output_hex)
    #                 error = 1
    #                 break
    #             output_hex = output_file.readline().strip()
    #             hardware_output_hex = hardware_output_file.readline().strip()
    #         if(error == 0):
    #             print("Done. All results are correct!")

    # a = hex_to_bfloat("031f")
    # b = hex_to_bfloat("5bce")
    # print(a)
    # print(b)
    # c = a*b
    # print(c)

    # d = hex_to_bfloat("1F80")
    # print(d)



    

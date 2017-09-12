function [A,rsltpath] = img2Gcode(srcpath)
%UNTITLED �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
I=imread(srcpath);
if (ndims(I)==3) && (size(I,3)==3)   %���ǲ�ɫ����Ϊ�Ҷ�ͼ
    I=rgb2gray(I);
end

%����
I=imresize(I,[500,500]);
%imshow(I)%%%
I=im2bw(I);

%������Ԫ��A��˫��ӹ���
R=size(I,1);   
A=[];
flag=1;
a=1;
for i=1:R
    B=I(i,:);
    index=find(B==0);
    N=length(index);
    if N>0
        if flag==1
            j=1;
            while j<=N
                k=j+1;
                while (k<=N && index(k)-index(k-1)==1)
                    k=k+1;
                end
                A(a,:)=[i,index(j),index(k-1)];
                a=a+1;
                j=k;
            end
            flag=-1;
    
        elseif flag==-1
            j=N;
            while j>=1
                k=j-1;
                while (k>=1 && index(k+1)-index(k)==1)
                    k=k-1;
                end
                A(a,:)=[i,index(j),index(k+1)];
                a=a+1;
                j=k;
            end
            flag=1;
        end
    end
end

rsltpath=strcat(srcpath,'_Gcode.txt');
%�ɾ���A����G����
fp=fopen(rsltpath,'w+');
%x0,y0����ʼλ��
x0=15000-1000-9000-7500;
y0=245000+4000+7000+5000;
%�ȶ�λ�����Ͻ�
fprintf(fp,'N0 G90\r\n');
fprintf(fp,'N1 G00 X%d.0 Y%d.\r\n',x0,y0);
fprintf(fp,'N2 G01 X%d.0 Y%d.0 E+300000 E-300000 F20000\r\n',x0,y0);
fprintf(fp,'N3 G36 M555 K0 \r\n');

n=4;
R=size(A,1);

for i=1:R
    r=A(i,1); c=A(i,2);
    %y�ı��ʽҪ�� y=...-r*100
    y= y0-r*100; x= x0-c*100;
    fprintf(fp,'N%d G00 X%d.0 Y%d.0\r\n',n,x,y);n=n+1;
    c=A(i,3);
    x= x0-c*100;
    fprintf(fp,'N%d G36 M555 K1 \r\n',n);n=n+1;
    fprintf(fp,'N%d G01 X%d.0 Y%d.0\r\n',n,x,y);n=n+1;
    fprintf(fp,'N%d G36 M555 K0\r\n',n);n=n+1;
    i=i+1;
end

fprintf(fp,'N%d G36 M82 K1 \r\n',n);n=n+1; 
fclose(fp);

end


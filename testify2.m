
%%导言区
%用来测试ui的各项功能分区布局
%请选择合适的高斯滤波的sigma值否则用sobel边缘检测的时候容易检测不到边缘
%倘若找不到边缘可能是sigma的值不太好或者不适合利用sobel模版进行边缘检测
%%
h = figure('menubar','none','NumberTitle','off',...                   %创建出图形对象
                 'Name','20177740--山东搬砖大学的农民工之canny边缘提取',...
                 'Position',[300 120 1000 680],...
                 'tag','figure1');
%%
%%创建uimenu菜单栏(加载原始图像)
m1 = uimenu('label','加载原始图像','position',1,...                  %创建第一个菜单栏
                      'tag','menu1');
%%创建uimenu菜单栏(canny算子提取)
m2 = uimenu('label','canny算子边缘提取','position',2,...                             
                      'Callback',['set(m4,''checked'',''off'');',...
                                       'set(m2,''checked'',''off'');',...
                                       'set(m3,''checked'',''off'');',...
                                       'set(m5,''checked'',''off'');',...
                                       'set(m6,''checked'',''off'');'],...
                        'tag','menu2' ); 
m3 = uimenu('label','高斯滤波平滑图像',...
                      'parent',m2,'position',1,....
                      'Callback',['set(m2,''checked'',''off'');'...
                                       'set(m4,''checked'',''off'');',...
                                       'set(m3,''checked'',''on'');',...
                                       'set(m5,''checked'',''off'');',...
                                       'set(m6,''checked'',''off'');'],...
                       'tag','menu3');                                                                      
 m4 = uimenu('label','一阶偏导计算梯度幅值和方向',...
                       'parent',m2,'position',2,...
                       'Callback',['set(m2,''checked'',''off'');',... 
                                        'set(m3,''checked'',''off'');',...
                                        'set(m4,''checked'',''on'');',...
                                        'set(m5,''checked'',''off'');',...
                                        'set(m6,''checked'',''off'');'],...
                        'tag','menu4');
 m5 = uimenu('label','梯度赋值进行非极大值抑制',...
                       'parent',m2,'position',3,...
                       'Callback',['set(m2,''checked'',''off'');',... 
                                        'set(m3,''checked'',''off'');',...
                                        'set(m4,''checked'',''off'');',...
                                        'set(m5,''checked'',''on'');',...
                                        'set(m6,''checked'',''off'');'],...
                        'tag','menu5');
  m6  = uimenu('label','双阈值算法检测和连接边缘',...
                         'parent',m2,'position',4,...
                         'Callback',['set(m2,''checked'',''off'');',... 
                                        'set(m3,''checked'',''off'');',...
                                        'set(m4,''checked'',''off'');',...
                                        'set(m5,''checked'',''on'');',...
                                        'set(m6,''checked'',''on'');'],...
                          'tag','menu6');                              
%%退出按钮部分
 m12 = uimenu('label','退出界面',...
                         'position',3,...
                         'tag','menu12');
 %%创建句柄
 handles = guihandles(h);
 %%
 %%设置按钮的callback属性为函数句柄
 set(m1,'callback',@m1_callback);
 set(m3,'callback',@m3_callback);
 set(m4,'callback',@m4_callback);
 set(m5,'callback',@m5_callback);
 set(m6,'callback',@m6_callback);
 set(m12,'callback',@m12_callback);
 %%
 %%编写回调函数部分
 function [] = m1_callback(source,evendata)
             handles = guidata(source);
            [filename,path] = uigetfile({'*.';'*.jpg';'*.png';'*.jpeg';'*.bmp';;},'选择图片');
             try  isa(filename,'numeric');                       
             truename = [ path,filename ];              %拼接真正的路径名
             im = imread(truename);                        %显示图片
             subplot(2,3,1);                         
             imshow(im);
             chicun = size(im);
             switch numel(chicun)
                 case 2
                     im1 = im;
                 case 3
                     im1 = rgb2gray(im);
             end
             im1 = double(im1);                                 %读入的是uint8类型，要转double才能计算
             handles.im1 = im1;
             guidata(source,handles);
             title('原始图像','fontsize',20);
             catch
             warn = errordlg('你取消了选择,请勾选文件','File Error');
             end
 end
 %%
 function [] = m3_callback(menu3,evendata)     
                handles = guidata(menu3);                    %得到句柄 
            try
                im1 = handles.im1;                                %传递出im的参数  
                msg = inputdlg(['请输入\sigma的值']);         %对话框的提示
                true_msg = str2num(cell2mat(msg));
                %输入数字进行判断
                    try
                        im2 =  imgaussfilt(im1,true_msg);   %高斯滤波 \sigma = 自己输入的值
                        subplot(2,3,2);
                        imshow(uint8(im2));
                        title(['高斯滤波后的图像,\sigma = ' cell2mat(msg) ],'fontsize',20);   %title
                        handles.im2 = im2;                                %存储原始的影像
                    %如果不是0-1的数字或者不是数字
                    catch
                        if isempty(true_msg) == 1
                            warning = warndlg('请输入数字');       %请输入一个数字                                  
                        elseif true_msg<0 
                            warning = warndlg('请输入一个大于0的数字');    
                      end
                end
                guidata(menu3,handles);                      %存储句柄
            %如果没有先选定数字的话
            catch
                warn = warndlg('请先选择原始图像');
            end
 end
 function [] = m4_callback(menu4,evendata)
         
            handles = guidata(menu4);    
            try 
            im2 =  handles.im2;                               %拿到高斯滤波后的图像
           % f  = handles.f;
           % axes(handles.axes1);
            %imshow(uint8(im2));                                          %显示高斯滤波后的图像
            %title(['高斯滤波后的图像,\sigma = ',f],'fontsize',20);
            w = fspecial('sobel');                               %用sobel算子进行边缘检测
            im3h = imfilter(im2,w,'replicate');              %横边缘
            w =  [-1,0,1;-2,0,2;-1,0,1];
            im3v = imfilter(im2,w,'replicate');             %纵边缘
            im3 = sqrt(im3h.^2 + im3v.^2);               %平方再求和
            subplot(2,3,3);                         
            imshow(uint8(im3));                                          %显示sobel边缘提取后的图像
            title('一阶偏导计算幅值和方向导数','fontsize',20);
            arah = atan2(im3v,im3h);
            arah = arah*180/pi;
            handles.im3 = im3;                                 %存储一阶方向导数计算的图像
            handles.arah = arah;
            guidata(menu4,handles);
         catch
            warn = warndlg('请先输入高斯滤波后的图像');
         end
 end
 function m5_callback(menu5,evendata)           %梯度幅值的计算按钮
            handles = guidata(menu5);
            try 
            arah = handles.arah;
            im3 = handles.im3;
            [m,n] = size(im3);
            for i = 1:m
                for j = 1:n
                     if((arah(i,j)>=-22.5 && arah(i,j)<=22.5) || (arah(i,j)>=157.5 && arah(i,j)<=180)...
                                       ||(arah(i,j)<=-157.5 && arah(i,j)>=-180) )
                      arah(i,j) = 0;
                     elseif((arah(i,j) >= 22.5) && (arah(i,j) < 67.5) || (arah(i,j) <= -112.5) && (arah(i,j) > -157.5))
                       arah(i,j) = -45;
                      elseif((arah(i,j) >= 67.5) && (arah(i,j) < 112.5) || (arah(i,j) <= -67.5) && (arah(i,j) >- 112.5))
                       arah(i,j) = 90;
                       elseif((arah(i,j) >= 112.5) && (arah(i,j) < 157.5) || (arah(i,j) <= -22.5) && (arah(i,j) > -67.5))
                       arah(i,j) = 45;  
                     end
                end
            end
Nms = zeros(m,n);
            for i = 2:m-1
                for j= 2:n-1
                    if (arah(i,j) == 90 && im3(i,j) == max([im3(i,j), im3(i,j+1), im3(i,j-1)]))
                         Nms(i,j) = im3(i,j);
                     elseif (arah(i,j) == 45 && im3(i,j) == max([im3(i,j), im3(i+1,j-1), im3(i-1,j+1)]))
                        Nms(i,j) = im3(i,j);
                     elseif (arah(i,j) == 0 && im3(i,j) == max([im3(i,j), im3(i+1,j), im3(i-1,j)]))
                        Nms(i,j) = im3(i,j);
                      elseif (arah(i,j) == -45 && im3(i,j) == max([im3(i,j), im3(i+1,j+1), im3(i-1,j-1)]))
                        Nms(i,j) = im3(i,j);
                    end
                end
                subplot(2,3,4);
                imshow(Nms);
                title('非极大值抑制','fontsize',20);  
            end
                 handles.Nms = Nms;
                 handles.m = m;
                 handles.n =  n;
                 guidata(menu5,handles);
            catch
                 warn = warndlg('请先输入梯度幅值计算后的图像');  
        end
 end
 %%
 function m6_callback(menu6,~)
                handles = guidata(menu6);
                try 
                    im1 = handles.im1;
                    im3 = handles.im3;
                    Nms = handles.Nms;
                    [m,n] = size(im3);
                    img_out=zeros(m,n);                         %定义一个双阈值图像
                    YH_L=0.08*max(max(Nms));            %低阈值
                    YH_H=0.24*max(max(Nms));            %高阈值
                for i = 1:m
                    for j = 1:n
                        if(Nms(i,j)<YH_L)
                            img_out(i,j)=0;
                        elseif(Nms(i,j)>YH_H)
                            img_out(i,j)=1;
 %对TL < Nms(i, j) < TH 使用8连通区域确定
                  elseif ( Nms(i+1,j) < YH_H || Nms(i-1,j) < YH_H || Nms(i,j+1) < YH_H || Nms(i,j-1) < YH_H ||...
                    Nms(i-1,j-1) < YH_H || Nms(i-1, j+1) < YH_H || Nms(i+1, j+1) < YH_H || Nms(i+1, j-1) < YH_H)
                    img_out(i,j) = 1;   
                        end  
                    end
                end
                    subplot(2,3,5);
                    imshow(img_out);
                    title('自做canny边缘','fontsize',20);
                    cannyedge = edge(im1,'canny');
                    subplot(2,3,6);
                    imshow(cannyedge);
                    title('库函数的canny边缘','fontsize',20);
                    pause(3);
             catch
                warn = warndlg('你尚未输入NMS后的图像');         
             end
 end
 %%退出按钮
 function   m12_callback(~,~,handles)
               clf;clear all;close all;
 end 

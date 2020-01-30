%     -------------Brief description-------------------
%     This demo contains the implementation of the algorithm for video rain streaks removal
%     An early material of the this menthod is:
%     Tai-Xiang Jiang, Ting-Zhu Huang, Xi-Le Zhao, Liang-Jian Deng, Yao Wang;
%     ''A Novel Tensor-Based Video Rain Streaks Removal Approach via Utilizing Discriminatively Intrinsic Priors'' The IEEE Conference on Computer Vision and Pattern Recognition (CVPR), 2017, pp. 4057-4066
%         @InProceedings{Jiang_2017_CVPR,
%         author = {Jiang, Tai-Xiang and Huang, Ting-Zhu and Zhao, Xi-Le and Deng, Liang-Jian and Wang, Yao},
%         title = {A Novel Tensor-Based Video Rain Streaks Removal Approach via Utilizing Discriminatively Intrinsic Priors},
%         booktitle = {The IEEE Conference on Computer Vision and Pattern Recognition (CVPR)},
%         month = {July},
%         pages = {2818-2827},
%         doi={10.1109/CVPR.2017.301},
%         year = {2017}}
%     The preprint of the extended journal version:
%     Tai-Xiang Jiang, Ting-Zhu Huang, Xi-Le Zhao, Liang-Jian Deng, Yao Wang; “Fastderain: A novel video rain streak removal method using directional gradient priors,” ArXiv e-prints, 2018.
%     is now vailable at https://arxiv.org/abs/1803.07487.
%         @article{Jiang2018FastDeRain,
%         author = {Jiang, Tai-Xiang and Huang, Ting-Zhu and Zhao, Xi-Le and Deng, Liang-Jian and Wang, Yao},
%         title = {FastDeRain: A Novel Video Rain Streak Removal Method Using Directional Gradient Priors},
%         journal = {ArXiv e-prints},
%         archivePrefix = "arXiv",
%         eprint = {1803.07487},
%         year = {2018},
%         url = {https://arxiv.org/pdf/1803.07487.pdf}}
%
%   Contact: taixiangjiang@gmail.com
%   Date: 03/03/2018

clear all;close all;clc;
path(path,genpath(pwd));
%%--- Load Video ---%%%
load foreman_rainy.mat   % Rainy video  ( "foreman" with the synthetic rain streaks in case 2) and parameter opts
load foreman_clean.mat  % Clean video



[O_Rainy,~]=rgb2gray_hsv(Rainy);   %rgb2hsv
[O_clean,O_hsv]=rgb2gray_hsv(B_clean);
Rain = O_Rainy-O_clean;
O_Rainy = gpuArray(O_Rainy);
O_clean = gpuArray(O_clean);
fprintf('Index      | PSNR    | MSSIM   | MFSIM   | MVIF   |  MUIQI | MGMSD\n'); 

PSNR0 = psnr(Rainy(:),B_clean(:),max(B_clean(:)));
MPSNR0 = MPSNR(Rainy,B_clean);
MSSIM0 = MSSIM(Rainy,B_clean);
MFSIM0 = MFSIM(Rainy*255,B_clean*255);
MUQI0 = MUQI(Rainy*255,B_clean*255);
MVIF0 = MVIF(Rainy*255,B_clean*255);
MGMSD0 = MGMSD(Rainy,B_clean);

fprintf('Rainy       |   %.4f   |   %.4f   |   %.4f   |   %.4f   |   %.4f   |   %.4f  \n',PSNR0,MSSIM0 ,MFSIM0,MVIF0,MUQI0,MGMSD0);

%% FastDeRain
%%%      Main model:
%%%      $\min\limits_{\mathcal{B,R,Vi,Di}}\quad\lambda_1||\mathcal{V_1}||_1+\lambda_2||\mathcal{V}_2||_1+\lambda_3||\mathcal{V}_3||_1+\lambda_4||\mathcal{V}_4||_1$
%%%         s.t.
%%%              $\mathcal{V}_1=D_y(\mathcal{R})$ 
%%%              $\mathcal{V}_2=\mathcal{R}$
%%%              $\mathcal{V}_3=D_x(\mathcal{B})$
%%%              $\mathcal{V}_4=D_t(\mathcal{B})$
%%%
%%%   input:      the original rainy video $\mathcal{O}$
%%%   output:     1 the rainy steak $\mathcal{R}$   2 the rain-free video $\mathcal{B}$    

%%%     Parameters :
%%%     opts.lam1   =>  $\lambda_1$
%%%     opts.lam2   =>  $\lambda_2$
%%%     opts.lam3   =>  $\lambda_3$
%%%     opts.lam4   =>  $\lambda_4$
%%%     opts.mu     =>  $\mu$
%%%     opts.tol    =>  stopping rriterion   
%%%     opts.maxit  =>  maxium iteration  

    tStart =  tic;
    [B_1,R_1,iter] = FastDeRain_GPU(O_Rainy,opts);
    time = toc(tStart);
    B_c = gray2color_hsv(O_hsv,gather(B_1));
PSNR1 = psnr(B_c(:),B_clean(:),max(B_clean(:)));
MPSNR1 = MPSNR(B_c,B_clean);
MSSIM1 = MSSIM(B_c,B_clean);
MFSIM1 = MFSIM(B_c*255,B_clean*255);
MVIF1 = MVIF(B_c*255,B_clean*255);
MUQI1 = MUQI(B_c*255,B_clean*255);
MGMSD1 = MGMSD(B_c,B_clean);

fprintf('FastDeRain |   %.4f   |   %.4f   |   %.4f   |   %.4f   |   %.4f   |   %.4f  \n',PSNR1,MSSIM1 ,MFSIM1,MVIF1,MUQI1,MGMSD1);
             
fprintf('FastDeRain running time (GPU) :    %.4f  s\n', time);




function [ jbase ] = configueJbase()
%% �Լ����� : Jacobian ����� �����մϴ�. 
% Jacobian (charge + potential) �� potential �κ��� ���� 

%% �۷ι� �����κ��� ����� �ҷ��ɴϴ�. 
global xmesh;   % x���� mesh 
global zmesh;   % z���� mesh 
global const_p; % ��ġ�� ���� �޶����� ���

% x���� �ε���, ���� �������� 
nx = xmesh.nx;          % �� ��� 
x_int1 = xmesh.int1;    % �ε��� (��� ����)
x_int2 = xmesh.int2;    % �ε��� (��� ������)
x_dlt  = xmesh.dlt;     % ��� ����

% z���� �ε���, ���� �������� 
nz = zmesh.nz;          % �� ��� 
z_int1 = zmesh.int1;    % �ε��� (��� ����)
z_int2 = zmesh.int2;    % �ε��� (��� ������)
z_dlt  = zmesh.dlt;     % ��� ����

% ��� �ҷ����� 
eps_r    = const_p.eps_r;
boundary = const_p.boundary;
 
%% ��� ��ġ���� ��� ������ ���� 
% z���� ��� ��ġ���� ���� ���� ������ ����   
eps_x = eps_r;
eps_x(:,z_int1) = bsxfun(@times, eps_r(:,z_int1), (z_dlt(z_int1-1)./(z_dlt(z_int1-1)+z_dlt(z_int2)))' ) ...
                + bsxfun(@times, eps_r(:,z_int2), (z_dlt(z_int2)  ./(z_dlt(z_int1-1)+z_dlt(z_int2)))' );
            
eps_left        = eps_x(2:end,:);
eps_left(end,:) = eps_x(end,:)*2;   % Neumann ������� 

% z���� ��� ��ġ���� ������ ���� ������ ����    
eps_right           = eps_x(1:end-1,:);
eps_right(x_int1,:) = eps_x(x_int2,:);  % x_int1���� ������ field�� x_int2�� ������ field ���� 
eps_right(1,:)      = eps_x(1,:)*2; % Neumann ������� 

% x���� ��� ��ġ���� �Ʒ��� ���� ������ ����   
eps_z = eps_r;
eps_z(x_int1,:) = bsxfun(@times, eps_r(x_int1,:), x_dlt(x_int1-1)./(x_dlt(x_int1-1)+x_dlt(x_int2)) ) ...
                + bsxfun(@times, eps_r(x_int2,:), x_dlt(x_int2)  ./(x_dlt(x_int1-1)+x_dlt(x_int2)) );
            
eps_lower        = eps_z(:,2:end);
eps_lower(:,end) = eps_z(:,end)*2;  % Neumann ������� 

% x���� ��� ��ġ���� ���� ���� ������ ����   
eps_upper           = eps_z(:,1:end-1);
eps_upper(:,z_int1) = eps_z(:,z_int2);  % z_int1���� ���� field�� z_int2�� ���� field ���� 
eps_upper(:,1)      = eps_z(:,1)*2; % Neumann ������� 

%% �� ��ġ���� ����, ������, �Ʒ���, ���� field ��� 
% ����: Poisson �������� ���н����� ����, 3D�κ��� homogeneous������ ����� 2D ��ȯ. 
%      ��, 6���� �������� 4���� ���������� ��ȯ�� 
% ���� ���� ������ ���� 
delta_n = x_dlt; 
delta_p = [x_dlt(2:end) ; x_dlt(end)];
j_left  = zeros(nx, nz);
j_left(2:end,:)  = bsxfun(@rdivide, eps_left, delta_n.*(delta_p+delta_n)/2 );
% j_left(2:end,:)  = bsxfun(@rdivide, eps_left, 1);
j_cent1 = -j_left;

% ������ ���� ������ ���� 
delta_n = [x_dlt(1) ; x_dlt(1:end-1)]; 
delta_p = x_dlt;
j_right  = zeros(nx, nz);
j_right(1:end-1,:)  = bsxfun(@rdivide, eps_right, delta_p.*(delta_p+delta_n)/2 );
% j_right(1:end-1,:)  = bsxfun(@rdivide, eps_right, 1);
j_cent2 = -j_right;

% �Ʒ��� ���� ������ ���� 
delta_n = z_dlt;
delta_p = [z_dlt(2:end) ; z_dlt(end)];
j_lower  = zeros(nx, nz);
j_lower(:,2:end) = bsxfun(@rdivide, eps_lower, (delta_n.*(delta_p+delta_n)/2)' );
% j_lower(:,2:end) = bsxfun(@rdivide, eps_lower, 1);
j_cent3 = -j_lower;

% ���� ���� ������ ���� 
delta_n = [z_dlt(1) ; z_dlt(1:end-1)];
delta_p = z_dlt;
j_upper  = zeros(nx, nz);
j_upper(:,1:end-1) = bsxfun(@rdivide, eps_upper, (delta_p.*(delta_p+delta_n)/2)' );
% j_upper(:,1:end-1) = bsxfun(@rdivide, eps_upper, 1);
j_cent4 = -j_upper;

%% ���� field�� ���� Jacobian ��� ���� 
% Jacobian ��� ������� ���� 
jbase = zeros(nx*nz, nx*nz, 2); % 3��° index�� 1: x���� field, 2: z���� field�� �ǹ�

% x�������� ��� ���� 
j_cent1 = matrixToVector(j_cent1,nx,nz);  % �߾�1 : 2�������� 1�������� 
j_left  = matrixToVector(j_left, nx,nz);  % �߾�1 ���� : 2�������� 1�������� 
j_cent2 = matrixToVector(j_cent2,nx,nz);  % �߾�2 : 2�������� 1�������� 
j_right = matrixToVector(j_right,nx,nz);  % �߾�2 ������ : 2�������� 1�������� 

% �ش� ��ġ�� field ���� ���� 
jbase(2:end, 2:end,     1) = jbase(2:end, 2:end,     1) + diag(j_cent1(2:end));     % �߾�1(digaonal) ��ġ
jbase(2:end, 1:end-1,   1) = jbase(2:end, 1:end-1,   1) + diag(j_left (2:end));     % �߾�1 ���� ��ġ
jbase(1:end-1, 1:end-1, 1) = jbase(1:end-1, 1:end-1, 1) + diag(j_cent2(1:end-1));   % �߾�2(digaonal) ��ġ
jbase(1:end-1, 2:end,   1) = jbase(1:end-1, 2:end,   1) + diag(j_right(1:end-1));   % �߾�2 ������ ��ġ

% z�������� ��� ���� 
j_cent3 = matrixToVector(j_cent3,nx,nz);  % �߾�3 : 2�������� 1�������� 
j_lower = matrixToVector(j_lower,nx,nz);  % �߾�3 �Ʒ��� : 2�������� 1�������� 
j_cent4 = matrixToVector(j_cent4,nx,nz);  % �߾�4: 2�������� 1�������� 
j_upper = matrixToVector(j_upper,nx,nz);  % �߾�4 ���� : 2�������� 1�������� 

% �ش� ��ġ�� field ���� ���� 
jbase(1+nx:end, 1+nx:end, 2) = jbase(1+nx:end, 1+nx:end, 2) + diag(j_cent3(1+nx:end));  % �߾�3(digaonal) ��ġ
jbase(1+nx:end, 1:end-nx, 2) = jbase(1+nx:end, 1:end-nx, 2) + diag(j_lower(1+nx:end));  % �߾�3 �Ʒ��� ��ġ
jbase(1:end-nx, 1:end-nx, 2) = jbase(1:end-nx, 1:end-nx, 2) + diag(j_cent4(1:end-nx));  % �߾�4(digaonal) ��ġ
jbase(1:end-nx, 1+nx:end, 2) = jbase(1:end-nx, 1+nx:end, 2) + diag(j_upper(1:end-nx));  % �߾�4 �Ʒ��� ��ġ 

% Jacobian ��� ���� 
jbase = jbase(:,:,1) + jbase(:,:,2);

%% ���� ó�� 
% #1. ��� ó��
% ���� : �� ������ ������ ����� �ִٰ� �ϸ� ��鿡 ���� ����� �¿�(�Ǵ� ����) �� ���� ��带 �Ҵ��Ͽ� �ؼ�. 
%        �׷��� Poisson ������ �ؼ� �ÿ��� �� ���� �ƴ� �ϳ��� ��忡���� �ؼ� 
%        �׷��� x����(x�� �����ϴ�) ��鿡�� ���� ��带, z����(z�� �����ϴ�) ��鿡���� �Ʒ��� ��带 �����Ͽ� �ؼ�. 
%        �̿� ���� �߻��ϴ� ���� ��Ȳ���� ���� �����Ͽ���. 
% ��� ó�� (x����) : x_int1���� field�� ����� �� ��� ��尡 �ƴ� �� ������ ��带 �����ϵ��� ����. x_int2�� x_int1 ����.   
for i = 1:size(x_int1,1)
    for j = 0:nz-1
        x1 = x_int1(i) + j*nx;
        x2 = x_int2(i) + j*nx;
        jbase(x1,x2+1) = jbase(x1,x2);  % x_int1������ �����Ŀ� x_int2�� ������ ��带 ����
        jbase(x1,x2  ) = 0;             % x_int1������ �����Ŀ� x_int2�� �������� ���� 

        jbase(x2,:)  = 0;   % x_int2���� ������ �ĵ��� ��� �������� 
        jbase(x2,x2) = 1;   % x_int2������ �������� x_int1�� �������� ������ ��ü 
        jbase(x2,x1) = -1;
    end 
end

% ��� ó�� (z����) : z_int1���� field�� ����� �� ��� ��尡 �ƴ� �� ���� ��带 �����ϵ��� ����. z_int2�� z_int1 ����.
for i = 1:nx
    for j = 1:size(z_int1,1)
        z1 = i+(z_int1(j)-1)*nx;
        z2 = i+(z_int2(j)-1)*nx;
        jbase(z1,z2+nx) = jbase(z1,z2);     % z_int1������ �����Ŀ� z_int2�� ���� ��带 ����
        jbase(z1,z2   ) = 0;                % z_int1������ �����Ŀ� z_int2�� �������� ���� 

        jbase(z2,:)  = 0;   % z_int2���� ������ �ĵ��� ��� �������� 
        jbase(z2,z2) = 1;   % z_int2������ �������� z_int1�� �������� ������ ��ü 
        jbase(z2,z1) = -1;
    end 
end

% ��� ó�� (x����, z���� ���� ����) : �밢���� ��ġ�� xz_int2�� xz_int1 ����
for i = 1:size(x_int1,1)
   for j  = 1:size(z_int1,1)
       xz1 = x_int1(i) + (z_int1(j)-1)*nx;
       xz2 = x_int2(i) + (z_int2(j)-1)*nx;
       
       jbase(xz2, :) = 0;       % xz_int2���� ������ �ĵ��� ��� �������� 
       jbase(xz2, xz2) = 1;     % xz_int2���� �������� xz_int1�� �������� ������ ��ü 
       jbase(xz2, xz1) = -1;
   end
end

% #2. ��� ���� ó�� 
% ��� ���� ���� (Dirichlet boundary) 
jbase_BC = eye(nx*nz);          
BC_index = find(boundary ~= 0); % ��� ���ǿ� �ش��ϴ� ��ġ�� ���
jbase(BC_index,:) = jbase_BC(BC_index,:);    % identity ��Ŀ��� �ش��ϴ� ���� �����Ͽ� Jacobian �࿡ �ٿ��ֱ�

end























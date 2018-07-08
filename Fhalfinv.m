function [ integration ] = Fhalfinv( E, nE, m)
%% �־��� �������� ���� Fermi function�� ����մϴ�. (y(homogenous) �������� Fermi-Dirac ����)
% �� �Ķ���ʹ� ������ �����ϴ�. 
% E: ������ ���� (1���� ��̸� ó�� ����)
% nE : ������ ��� ����
% m : ��ȿ ���� ���� (homogeneous ����)

% �຤�ʹ� �����ͷ� ��ȯ�Ͽ� ó��. 
tOption = 0; % transpose option 
if size(E,2) == 1   % ������ 
    tOption = 0;
elseif size(E,1) == 1   % �຤��
    tOption = 1;
    E = E';
else
    disp('Error: Invalid Input Format (Fermi integral)');
    integration = 0;
    return;
end

% �۷ι� �����κ��� ��� �ҷ����� 
global xmesh;
delta = xmesh.dlt(1)*1e-9;  % nm ȯ�� 
global const_i;
q = const_i.q;
Vt = const_i.Vt;
hBar = const_i.hBar;

% kBT�� �������� Ey�� �������� ���� 
eps = linspace(0, 10, nE);  % y���� ������ ��� [1]
d_eps = eps(2) - eps(1);    % ������ ���� 
eps = eps(1:end-1) + d_eps/2;   % ����(���б�����)�� ���� ��� �� �߰����� ��� 
[eps_mat, E_mat] = meshgrid(eps, E);    % 2�������� �����Ͽ� ��� 
% (���� �޶����� y���� ��������, ���� �޶����� �־��� �������� ����)
eps2_mat = eps_mat + d_eps/2;   % ���� ����� ���� ��ġ 
eps1_mat = eps_mat - d_eps/2;   % ���� ����� ������ ��ġ 

% ������ ������ ��� 
integration = (hBar*delta)^-1*sqrt(m*q*Vt/2)/pi*sum( 2*(1./(1+exp(eps_mat - E_mat/Vt))).*(sqrt(eps2_mat) - sqrt(eps1_mat)), 2 );

if tOption == 1 % �Է��� �຤�Ϳ����� transpose
    integration = integration';
end 
end


function [ nn ] = negf_Transport( valleyNum, Em, Vm, k_count, E, FF1, FF2 )
%% �Լ����� : NEGF�� �̿��Ͽ� �������� ����մϴ�.
% �� �Ķ���ʹ� ������ �����ϴ�. 
% valleyNum : x���������� valley ��ȣ (#1: m_l, #2 & #3 : m_t)
% Em : mode ������(subband minimum)
% Vm : �ĵ��Լ� 
% k_count : �ؼ��� mode ��ȣ 
% E : �ؼ��� ����� ������ ��� ��� 
% FF1 : Source�ܿ����� Fermi �Լ���, E index�� ����
% FF2 : Drain�ܿ����� Fermi �Լ���, E index�� ����

%% �۷ι� ����� �ҷ��ɴϴ�. 
if (3 < valleyNum ) || (valleyNum < 1)  % ���� üũ (1~3)
    disp(sprintf('option : out of range!'));
    return;
end
global mass;    % valley�� ���� ���� ��ȿ ���� 
m_x = mass.m_x(valleyNum);

global xmesh;   % x���� mesh 
global zmesh;   % z���� mesh
global const_i; % ��ġ�� ������ ���

% x���� ����, �� ��� ���� ��������
x_dlt = xmesh.dlt(1)*1e-9;
nx = xmesh.nx - 2;
% z���� �Ǹ��� ���� ��� ���� �������� 
nz = size(zmesh.idx{2}, 2);

% ��� �ҷ�����
q = const_i.q;
hBar = const_i.hBar;

% ������ ���� ��ȯ ([eV] -> [J])
E = E*q;
Em = Em(:,k_count)*q;

% �ش� mode ��ȣ�� �´� �ĵ��Լ� �������� 
Vm = Vm(:,:,k_count);

%% NEGF �ؼ��� ����  
% Hamiltonian ��� �� T�� ���� : H = T(kinetic energy) + U(potential energy)
t = +(hBar^2/(2*m_x*x_dlt^2));  % ��� t = hBar^2/(2 m a^2)
sbase_first_row = zeros(nx,1); 
sbase_first_row(1) = -2; sbase_first_row(2) = 1;
sbase = sparse(toeplitz(sbase_first_row, sbase_first_row'));
T = -t*sbase;   % T �ϼ�

% ������ ��� ������ 
nE = size(E,2)-1;   % ��꿡 ���� ������ ��� ����, ��� ������ ������ ���б������� ���
dE = E(2) - E(1);   % ������ ��� ����

% ��� ����
i = sqrt(-1);        % ��� i ���� 

% ���� ���� 
sigma1 = zeros(nx,nx);  % self ������ ���� (source)
sigma2 = zeros(nx,nx);  % self ������ ���� (drain)

nn_x = zeros(nx,nz);    % NEGF�� ���� ��� 2���� ���ڳ� 

A1 = zeros(nx, nE);     % spectral density (Local DOS) - source
A2 = zeros(nx, nE);     % spectral density (Local DOS) - drain 

% NEGF�� ���� ���ڳ� ��� ���� 
for j = 1:nE
    % ����� ������ ���� 
    E_l = E(j) + dE/2;  % ���б����� ����� ���� ������ ��忡�� �߰����� ���� 
    
    % ���� ������ ��� 
    % matlab acos �Լ��� [-1,+1]�� [��, 0]�� �����Ǵ� �� ������ 
    % [-1,+1] ���� ���������� ���Ҽ��� �����Ͽ� ������ �ʴ� ������ �� 
    % ������ �ʿ��� ������ ���� 
    E_ratio1 = 1 - ( E_l - Em(1) )/(2*t);
    ka1 = acos( E_ratio1 +2*(E_ratio1 < -2) +2*(E_ratio1 < -4) );   
    sigma1(1,1) = -t*exp(i*ka1);        
    E_ratio2 = 1 - ( E_l - Em(nx) )/(2*t);
    ka2 = acos( E_ratio2 +2*(E_ratio2 < -2) +2*(E_ratio2 < -4) );
    sigma2(nx, nx) = -t*exp(i*ka2);
    
    % �׸� �Լ� ��� 
    G = ( E_l*eye(nx) -T -diag(Em) - sigma1 - sigma2 )\eye(nx, nx);

    A1(:,j) = real(diag(G*i*(sigma1 - sigma1')*G'));    % source�κ����� Local DOS 
    A2(:,j) = real(diag(G*i*(sigma2 - sigma2')*G'));    % draindm�κ����� Local DOS 
end

% NEGF �ؼ� �� �������� ���� �����ϴ� ���ڳ󵵸� ���� (������ ����)
integ_sim2 = ( sum(bsxfun(@times, A1, FF1),2) + sum(bsxfun(@times, A2, FF2),2) )/(2*pi)*dE;
for pos = 1:nx % �� x��ġ�� ���Ͽ� 
    % �ĵ��Լ��� ������ ���Ͽ� z���������� ���ڳ� Ȯ�� 
    % factor 2�� ���� ����
    nn_x(pos,:) = nn_x(pos,:) + 2*integ_sim2(pos)*Vm(pos,:).^2;
end

if min(min(nn_x)) < 0
    disp('Error: n has negative value');
end

% ���ڳ󵵿� ���Ͽ� x��� ���� ������ ��鿡 ��带 �ϳ��� �߰�. (potential�� ȣȯ�� ����)
nn_index = [(1:xmesh.int2(1)-1)';...
            (xmesh.int2(1)+1:xmesh.int2(2)-1)';...
            (xmesh.int2(2)+1:nx+2)'];

nn = zeros(nx+2, zmesh.nz);
nn(nn_index, zmesh.idx{2}) = nn_x;
nn(xmesh.int2, :) = nn(xmesh.int2-1, :);

end


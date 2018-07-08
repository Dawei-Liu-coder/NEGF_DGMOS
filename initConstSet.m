function [ phi ] = initConstSet( Nd, Vgs )
%% �Լ����� : �ùķ��̼ǿ� �ʿ��� ������� �۷ι� ���� ���·� �����մϴ�. 
% �� �Ķ���ʹ� ������ �����ϴ�. 
% Nd : ���� �� (1x3 ��̿� �� ������ ���γ󵵸� ����)
% Vgs : Gate���� Dirichlet ��谪 

%% �۷ι� �����κ��� ����� �ҷ��ɴϴ�. 
global xmesh;   % x���� mesh 
global zmesh;   % z���� mesh 

%% �۷ι� ������ ����� �����մϴ�. 
% ni0 ���
% ni0 = 1.0750038e+10;    % [cm^-3]
% ni0 = 1.0758720e+10;    % [cm^-3]

% ��ġ�� ������ ���
global const_i;       % �۷ι� ���� ����           
const_i.q = 1.602192e-19;         % [J/eV] or [C]
const_i.Vt = 1.380662e-23*300/const_i.q;    % [V]
const_i.hBar = 1.054571726e-34;   % [J-s] 
const_i.m0 = 9.10938356e-31;      % [kg] ���� ����
const_i.eps0 = 8.8542e-12;      % [F/m] 
const_i.ni0 = 1.0758720e+10;    % [cm^-3]
const_i.eps_r_si = 11.7;        % [1]
const_i.eps_r_ox = 3.9;         % [1]
const_i.Egap = 1.11;            % [eV] �Ǹ��� bandgap

% ��ȿ ���� ����
global mass;        % �۷ι� ���� ����
ml = 0.98*const_i.m0;   % ml = 0.98m0
mt = 0.19*const_i.m0;   % mt = 0.19m0  
mass.m_x = [ml mt mt];  % x���� ��ȿ ���� [valley #1, #2, #3]
mass.m_y = [mt ml mt];  % y���� ��ȿ ���� [valley #1, #2, #3]
mass.m_z = [mt mt ml];  % z���� ��ȿ ���� [valley #1, #2, #3]

% ��ġ�� ���� �޶����� ��� 
global const_p;  
const_p.eps_r      = zeros(xmesh.nx, zmesh.nz);   % ��������� (left, right, bottom, top)
const_p.ni         = zeros(xmesh.nx, zmesh.nz);     % intrinsic ���� �� [m^-3]
const_p.doping     = zeros(xmesh.nx, zmesh.nz);     % ���� �� [m^-3]
const_p.boundary   = zeros(xmesh.nx, zmesh.nz);   % ��� ���� (phi, n, p)

% ���ټ� ���� ���� 
phi = zeros(xmesh.nx, zmesh.nz); 

% �ݼ� ���� �ε��� ���� 
% source �ݼ� �ε���
x_source = 1;   
z_source = [zmesh.int1(1) zmesh.idx{2} zmesh.int2(2)];  

% drain �ݼ� �ε���
x_drain  = xmesh.nx;  
z_drain  = z_source;              

% gate1 �ݼ� �ε���
x_gate1  = [xmesh.int1(1) xmesh.idx{2} xmesh.int2(2)];  
z_gate1  = 1;   

% gate2 �ݼ� �ε���
x_gate2  = x_gate1;                         
z_gate2  = zmesh.nz;  

%% ��ġ�� ���� �޶����� ��� ����
% ��� setting : ���������
const_p.eps_r(:,zmesh.idx{1}) = const_i.eps_r_ox;    % [1] in oxide.
const_p.eps_r(:,zmesh.idx{2}) = const_i.eps_r_si;    % [1] in semi.
const_p.eps_r(:,zmesh.idx{3}) = const_i.eps_r_ox;    % [1] in oxide.

% ��� setting : intrinsic ���� �� 
const_p.ni(:, zmesh.idx{1}) = 0;             % [m^-3] in oxide 
const_p.ni(:, zmesh.idx{2}) = const_i.ni0*1e+6;    % [m^-3] in semi.
const_p.ni(:, zmesh.idx{3}) = 0;             % [m^-3] in oxide

% ��� setting : ���� �� 
const_p.doping(:, zmesh.idx{1}) = 0;                % in oxide 
const_p.doping(xmesh.idx{1}, zmesh.idx{2}) = Nd(1)*1e+6;   % in semi. (n+)
const_p.doping(xmesh.idx{2}, zmesh.idx{2}) = Nd(2)*1e+6;   % in semi. (i)
const_p.doping(xmesh.idx{3}, zmesh.idx{2}) = Nd(3)*1e+6;   % in semi. (n+)
const_p.doping(:, zmesh.idx{3}) = 0;                % in oxide

% Dirichlet ��谪�� �Է� (phi)
const_p.boundary(x_gate1, z_gate1) = Vgs;    % gate (lower) 
const_p.boundary(x_gate2, z_gate2) = Vgs;    % gate (upper)
% boundary(x_source,z_source,1) = Vss;    % source (left)
% boundary(x_drain, z_drain, 1) = Vss;    % drain (right)

% �ʱ� Poisson �����Ŀ� ���� ���ټ� guess 
phi = initPotential(phi, const_p.doping, const_p.ni, const_i.Vt);

% Dirichlet ��������� �ʿ��� ��ġ�� ���ټ� �����
BC_index = find(const_p.boundary ~= 0);     % ��谪�� nonzero�� �ε����� ã�Ƽ�
phi(BC_index) = const_p.boundary(BC_index); % ���ټȿ� �ش� ���� ����� 
end


function [ Em, Vm ] = mode_Confinement( valleyNum, phi )
%% �Լ����� : ������ x��ġ���� z�������� Schrodinger �������� �ؼ�, mode �������� �ĵ��Լ��� ����ϴ�. 
% �� �Ķ���ʹ� ������ �����ϴ�. 
% valleyNum : z���������� valley ��ȣ (#1 & #2 : m_t, #3: m_l)
% phi : Schrodinger ������ �ؼ��� ����� ���ټ� 

%% �۷ι� ����� �ҷ��ɴϴ�. 
if (3 < valleyNum ) || (valleyNum < 1)  % ���� üũ (1~3)
    disp(sprintf('option : out of range!'));
    return;
end
global mass;    % valley�� ���� ���� ��ȿ ���� 
m_z = mass.m_z(valleyNum);

global xmesh;   % x���� mesh
global zmesh;   % z���� mesh
global const_i; % ��ġ�� ������ ���

% ��� ����, �� ��� ���� ��������
z_dlt = zmesh.dlt(zmesh.idx{2}(1))*1e-9;
nx = xmesh.nx - 2;
nz = size(zmesh.idx{2}, 2);

% ��� ������, �ĵ��Լ� ������� Ȯ��
Em = zeros(nx, nz);
Vm = zeros(nx, nz, nz);

% ��� ��ȯ : 
% ���� ��� ������ NEGF�� ����Ͽ� ��鿡 2�� �Ҵ�� ��� �� �� ���� �����ϰ� oxide���� ����
phi(xmesh.int2,:) = [];     % ��� ������ ��带 ���� 
phi = phi(:, zmesh.idx{2}); % �Ǹ��� ������ ���ټȸ� ������ 

% ��� �ҷ�����
q = const_i.q;
hBar = const_i.hBar;

%% Schrodinger ������ �ؼ��� ���� 
for i = 1:nx

    %% ���ټ��� conduction ��� �������� ��ȯ 
    phi_F = 0.560983627;
    Vsch = q*(-phi(i,:)+phi_F); % potential energy in J 

    % Hamiltonian ��� �� T�� ���� : H = T(kinetic energy) + U(potential energy)
    t = +(hBar^2/(2*m_z)).*(1./z_dlt^2);
    sbase_first_row = zeros(nz,1); 
    sbase_first_row(1) = -2; sbase_first_row(2) = 1;
    sbase = sparse(toeplitz(sbase_first_row, sbase_first_row'));
    T = -t*sbase;   % T �ϼ�

    H = T + diag(Vsch); % Hamiltonian ��� ����
    
    % Eigen value problem�� �ؼ� �� ����
    [vector, value] = eig(H);   % vector : Eigen ����, value : Eigen ������ 
    [value, index] = sort(diag(value));     % Eigen �������� ������������ ���� 
    vector = vector(:, index);             

    % mode �������� �ĵ��Լ��� ��� 
    normal = sum( bsxfun(@times, vector.^2, z_dlt),1 );  % normalization factor ��� 
    wave_sim = bsxfun(@rdivide, vector, sqrt(normal));   % normalization�� ���� �ĵ��Լ� ���
    Ek_sim = (value)';  %[J]
    
    Em(i,:) = Ek_sim/q;     % mode ������ [eV]
    Vm(i,:,:) = wave_sim;   % �ĵ��Լ� [m^-0.5]
end



end


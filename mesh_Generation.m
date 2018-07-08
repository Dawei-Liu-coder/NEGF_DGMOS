function [  ] = mesh_Generation(  )
%% �Լ����� : ������ ��ġ���� .csv�� �о� mesh�� �۷ι� ������ �����մϴ�. 

%% ��ġ ��� ���� 
% x��� �ҷ��ͼ� ��ġ, ����, ��踦 ���� 
last = csvread('xmesh_0.5.csv', 0, 0, [0 0 0 0]);   % ��� �� ���� 
posOfNode = csvread('xmesh_0.5.csv', 1, 0, [1 0 last 0])*1e+3;   % ��� ��ġ [nm]
numberOfNode = size(posOfNode,1);                   % ��� �� ���� 
delta = (posOfNode(2:end) - posOfNode(1:end-1));    % ��� ���� [nm]
int1 = find(delta == 0);        % ��� ���� �ε��� 
int2 = int1 + 1;                % ��� ������ �ε��� 
delta(int1) = delta(int2);    

% ���� ���е� ���� �� �ε��� ���� (�� ���·� ����)
idx = {1:int1(1)};            % ���� 1
for i = 2:size(int1,1)        % ���̿� ��ġ�� ���� 
    idx{end+1} = int2(i-1):int1(i);
end
idx{end+1} = int2(i):numberOfNode;  % ���� end

% x���� �۷ι� ������ ���� 
global xmesh;
xmesh.pos = posOfNode;      % ��ġ (���)
xmesh.nx = numberOfNode;    % �� ��� ���� 
xmesh.dlt = delta;          % ��� ���� (���)
xmesh.int1 = int1;          % ��� ���� ��� (���)
xmesh.int2 = int2;          % ��� ������ ��� (���)
xmesh.idx = idx;            % ���� �� �ε��� (���)

x = xmesh.pos;
x_int = xmesh.int2;
x(x_int) = [];
xmesh.node = x;             % ��ġ (��� �ߺ� ��� ����)

% z��� �ҷ��ͼ� ��ġ, ����, ��踦 ���� 
posOfNode = csvread('zmesh_0.125.csv', 1, 0, [1 0 59 0])*1e+3;  % ��� ��ġ [nm]
numberOfNode = size(posOfNode,1);                               % ��� �� ����
delta = (posOfNode(2:end) - posOfNode(1:end-1));  % ��� ���� [nm]
%     z_dlt = round(z_dlt*1e+3)*1e-3;
int1 = find(delta == 0);        % ��� ���� �ε��� 
int2 = int1 + 1;                % ��� ������ �ε��� 
delta(int1) = delta(int2);

% ���� ���е� ���� �� �ε��� ���� (�� ���·� ����)
idx = {1:int1(1)};          % ���� 1
for i = 2:size(int1,1)      % ���̿� ��ġ�� ���� 
    idx{end+1} = int2(i-1):int1(i);
end
idx{end+1} = int2(i):numberOfNode;      % ���� end

% z���� �۷ι� ������ ���� 
global zmesh;
zmesh.pos = posOfNode;      % ��ġ (���)
zmesh.nz = numberOfNode;    % �� ��� ���� 
zmesh.dlt = delta;          % ��� ���� (���)
zmesh.int1 = int1;          % ��� ���� ��� (���)
zmesh.int2 = int2;          % ��� ������ ��� (���)
zmesh.idx = idx;            % ���� �� �ε��� (���)

z_int = [zmesh.int1(1) zmesh.int2(2)];
z = zmesh.pos;
z(z_int) = [];
zmesh.node = z;
zmesh.int3 = z_int;         % ��ġ (��� �ߺ� ��� ����)

end

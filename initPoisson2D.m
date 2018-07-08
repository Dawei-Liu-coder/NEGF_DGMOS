function [phi, nn] = initPoisson2D(iterNum, jbase, phi)
%% �Լ����� : �ʱ� ���ټ� guess�� ���� Poisson �������� �ؼ��մϴ�.
% �� �Ķ���ʹ� ������ �����ϴ�. 
% iterNum : �ִ� iteration Ƚ��
% jbase : Jacobian ��� (potential�� ���� ������ ����)
% phi : ���ټ�

%% �۷ι� �����κ��� ����� �ҷ���
global xmesh; % x���� mesh 
global zmesh; % z���� mesh 
global const_i; % ��ġ�� ������ ���
global const_p; % ��ġ�� ���� �޶����� ��� 

% x���� �ε���, ���� �������� 
x_int1 = xmesh.int1;    % �ε��� (��� ����)
x_int2 = xmesh.int2;    % �ε��� (��� ������)
x_dlt = xmesh.dlt;      % ��� ����

% z���� �ε���, ���� �������� 
z_int1 = zmesh.int1;    % �ε��� (��� ����)
z_int2 = zmesh.int2;    % �ε��� (��� ����)
z_dlt = zmesh.dlt;      % ��� ����

% ��� �ҷ����� 
q = const_i.q;
Vt = const_i.Vt;
eps0 = const_i.eps0;
ni = const_p.ni;
doping = const_p.doping;        % �������� 
boundary = const_p.boundary;    % ������� ����
BC_index = find(boundary ~= 0); % ������ǿ� �ش��ϴ� ��ġ index

%% Newton-Raphson iteration�� ����
for i = 1:iterNum
    %% #1. residual vector ��� 
    % charge term�� ��� �� = q(p - n + Nd+)
    nn = ni.*exp(+phi/Vt);      % ���ڳ�
    pp = ni.*exp(-phi/Vt);      % Ȧ�� 
    g  = q*(pp-nn+doping);      % charge ��� 
    
    % ���� �ٸ� �� ���� ��鿡���� ����ó�� (��鿡���� �� ��尡 �Ҵ�Ǿ� ����) :
    % <x��� ������ ���> (��鿡 ���� ����� ����/������ �� ��尡 �Ҵ�Ǿ�����)
    % ���� ���: �ٸ� ���� ��鿡�� charge�� ����� �� ��� ����/������ ����� charge�� ��� ���ݿ� ���� ������
    % ������ ���: 0 (������ ��忡���� Poisson �������� �ؼ����� ����. charge�� �ݵ�� 0)
    % <z��� ������ ���> (��鿡 ���� ����� �Ʒ���/���� �� ��尡 �Ҵ�Ǿ�����)
    % �Ʒ��� ���: �ٸ� ���� ��鿡�� charge�� ����� �� ��� �Ʒ���/���� ����� charge�� ��� ���ݿ� ���� ������
    % ���� ���: 0 (���� ��忡���� Poisson �������� �ؼ����� ����. charge�� �ݵ�� 0)
    g(x_int1,:) = bsxfun( @times, g(x_int1,:), x_dlt(x_int1-1)./(x_dlt(x_int1-1)+x_dlt(x_int1)) ) ...
                + bsxfun( @times, g(x_int2,:), x_dlt(x_int1)  ./(x_dlt(x_int1-1)+x_dlt(x_int1)) );
    g(:,z_int1) = bsxfun( @times, g(:,z_int1), (z_dlt(z_int1-1)./(z_dlt(z_int1-1)+z_dlt(z_int1)))' ) ...
                + bsxfun( @times, g(:,z_int2), (z_dlt(z_int1)  ./(z_dlt(z_int1-1)+z_dlt(z_int1)))' );
    g(x_int2,:) = 0;    
    g(:,z_int2) = 0;
    
    % Dirichlet ��� ����ó�� (Poisson �������� �ؼ����� ����. charge�� �ݵ�� 0)
    g(BC_index) = 0;

    % 2�������� �����ϴ� ����� 1���� Residual vector�� ��ȯ 
    % matrixToVector(���, x��尹��, z��尹��) : 2���� ����� 1���� ��̷� ��ȯ�ϴ� �Լ� 
    r = ( jbase*matrixToVector(phi, xmesh.nx, zmesh.nz) - matrixToVector(boundary, xmesh.nx, zmesh.nz) )...
        *eps0*1e+9^2;              % ������ ���. (������, nm^-2)
    R = r + matrixToVector(g, xmesh.nx, zmesh.nz);

    %% #2. Jacobian matrix ���� 
    % potential�� ���� �̺е� charge term�� ���
    h = -(q/Vt)*(pp+nn);
    
    % �ٸ� ���� ��鿡���� ����ó���� #1������ ������ ������� ó�� 
    h(x_int1,:) = bsxfun( @times, h(x_int1,:), x_dlt(x_int1-1)./(x_dlt(x_int1-1)+x_dlt(x_int1)) ) ...
                + bsxfun( @times, h(x_int2,:), x_dlt(x_int1)  ./(x_dlt(x_int1-1)+x_dlt(x_int1)) );
    h(:,z_int1) = bsxfun( @times, h(:,z_int1), (z_dlt(z_int1-1)./(z_dlt(z_int1-1)+z_dlt(z_int1)))' ) ...
                + bsxfun( @times, h(:,z_int2), (z_dlt(z_int1)  ./(z_dlt(z_int1-1)+z_dlt(z_int1)))' );
    h(x_int2,:) = 0;
    h(:,z_int2) = 0;
    
    % Dirichlet ��� ����ó��
    h(BC_index) = 0;
    
    j = jbase*(eps0)*1e+9^2;        % ������ ���. (������, nm^-2)
    J = j + diag( matrixToVector(h, xmesh.nx, zmesh.nz) );
    
    %% #3. ���ټ� update ���� ��� �� ���ż� üũ 
    % Jacobian*delta_phi = -Residual -> delta_phi =  -inverse(Jacobian)*Residual�� ���
    invJ = inv(J);
    dphi = -invJ*R;
    dphiMat = vectorToMatrix(dphi, xmesh.nx, zmesh.nz); % ���� delta_phi�� 1���� ��̿��� 2���� ��ķ� ��ȯ
    
    phi = phi + dphiMat;    % ������Ʈ�� �ݿ� 
    dphiVec = matrixToVector(dphiMat, xmesh.nx, zmesh.nz);
    stop(i) = full(max(abs(dphiVec)));  % update �� �� �ִ밪�� error�� �����Ͽ� Ȯ�� 
    
%     disp(sprintf('initial Poisson trial[%d]-error: %d \n', i, stop(i)))

    if stop(i) < 1e-12 % error�� ���ذ� 1e-12���� ������ ���������Ͽ� ����� ���� 
        break;
    end
end

end 

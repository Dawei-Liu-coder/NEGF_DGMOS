clear;
set(0,'defaultfigurecolor',[1 1 1]);

%% �ùķ��̼� ���� ���� 
% #0. �⺻ ������ ���� (�޽� ������ / ��ġ / ��� ����) 
% #1. 2D Poisson �������� �ؼ� (�ʱ� potential ������ guess)
% #2. �������¿��� ���� self consistent loop�� ���� 
%   #2-1. NEGF �ؼ� (�Է�: potential, ���: ���ڳ�)
%   #2-2. Poisson ������ �ؼ� (�Է�: ���ڳ�, ���: potential)
%   #2-3. (#2-1, #2-2 ���� ���� potential ��ȭ �ִ밪�� error�� ����) 
%         i) error�� 0.5e-5 ���� ������ �������� �����Ͽ� #2-4�� �̵�
%         ii) error�� 0.5e-5 ���� ũ�� #2-1���� �ٽ� ���� 
%   #2-4. ������ solution(potential)���κ��� ������ ���, solution�� ���� 
% #3. ����� ���� bias point�� step��ŭ �����Ͽ� #2. �� ����

%% �ʱ� ���� ���� 
    clear -global;  % ���� �۷ι� ������ ��� ���� 
    %% bias ����
    Vg_bias = 0.1;  % Vgs [V]
    % �ݼ� - workfunction: 4.1 eV 
    % �Ǹ��� - electron affinity: 4.05 eV, bandgap: 1.11 eV
    % barrier height = 4.1 - (4.05 + 1.11/2) = -0.505 eV -> 0.505 V
    Vg_barrier  = 0.505; % [V]  
    Vgs = Vg_barrier + Vg_bias; % ����Ʈ 
    
    Nd = [2e+20 ; 0 ; 2e+20]; % ���� �� 

    %% (.csv) ���Ϸκ��� ��ġ ������ ���� 
    mesh_Generation();

    %% ��� ���� - �۷ι� ����� ����
    [ phi ] = initConstSet( Nd, Vgs );
                    
    %% Jacobian matrix ����
    jbase = configueJbase();
    return;

    %% �ʱ� Poisson ������ ����
    [ phi, nn  ] = initPoisson2D( 100, jbase, phi);
    

% ### variable explorer code ###
%     phi = originVariable(1,1,phi);
%     nn = originVariable(1,1,nn);
%     global const_p
%     doping = const_p.doping;
%     doping = originVariable(1,1,doping);
    
%     global xmesh
%     x = xmesh.node;
%     global zmesh
%     z = zmesh.node';
    
sweep_mode = 1; % 1: Vds sweep, 2: Vgs sweep
if sweep_mode == 1
    %% bias sweep ���� (Vds)
    bias = 0.5;     % ���� bias 
    nVds = 51;      % bias point ����
    Vds = linspace(0, bias, nVds);   % bias point ���� 
    Ids = Vds*0;    % �������� ������ ���� (Vds�� ���̰� ���ƾ� ��)
    Vgs_delta = 0;  % Vgs�� sweep���� �����Ƿ� 0
else
%     %% bias sweep ���� (Vgs) - �� ����� ���ؼ��� �ڵ� ������ �ʿ� 
%     bias = 0.5;     % 
%     nVgs = 51;      % 
%     Vgs_delta = linspace(0, bias, nVgs);     % simulation target 
%     Ids = Vgs_delta*0;  % 
% %     Vds = 0;        % Vds�� sweep���� �����Ƿ� 0
end

%% self-consistent loop
for i = 1:51
    %% �ش� bias point�� ���Ͽ� �̸� ������ ��� ������ �� ��忡 ���� Fermi integral�� ���
    deltaE = 0.25e-3;    % ������ ��� ���� 

    % valley ���� : valley #1(l,t,t) #2(t,l,t) #3(t,t,l)
    
    % z���� schrodinger �ؼ�
    [Em_t, Vm_t] = mode_Confinement( 1, phi);   % valley #1, #2
    [Em_l, Vm_l] = mode_Confinement( 3, phi);   % valley #3

    % E_l ������(longitudinal energy) ���� ���� 
    E1 = min(min(Em_t(:,1)),min(Em_l(:,1)))-0.3;    % ������: Em �ּҰ����� 0.3 ���� 
    E2 = max(max(Em_t(:,2)),max(Em_l(:,5)))+0.3;    % ����: Em �ִ밪���� 0.3 ���� 
    E1 = (round(E1/deltaE))*deltaE;     % ������ �������� deltaE ����� ����
    E2 = (round(E2/deltaE))*deltaE;     % ������ ������ deltaE ����� ����
    totalE = E1:deltaE:E2;  % ������ ��� ����

    nodeNum = 1000; % Fermi integral�� ���Ǵ� E_y ������ ���� ��� ���� 
    % y���� ��ȿ ���� #2: m_y = m_l*m0, #1, #3: m_y = m_t*m0
    FF1_t = configue_Ffunction( 1, nodeNum, 0, totalE);  % #1, #3 / source
    FF2_t = configue_Ffunction( 1, nodeNum, Vds(i), totalE);  % #1, #3 / drain (bias)
    FF1_l = configue_Ffunction( 2, nodeNum, 0, totalE);     % #2 / source
    FF2_l = configue_Ffunction( 2, nodeNum, Vds(i), totalE);     % #2 / drain (bias)
    
    %% self-consistent loop ����
    for j = 1:100
        phi_old = phi;
        tic;
       %% NEGF �ؼ�
       % valley ���� : #1(l,t,t) #2(t,l,t) #3(t,t,l)
       % z���� schrodinger �ؼ�
        [Em_t, Vm_t] = mode_Confinement( 1, phi);   % valley #1, #2 
        [Em_l, Vm_l] = mode_Confinement( 3, phi);   % valley #3 
        
        nn1 = phi*0; nn2 = nn1; nn3 = nn1; % nn1, nn2, nn3 ���庯�� ���� 
        for k = 1:2     % mode ���� 2�� ���, �� mode �� ���Ͽ� ���Ǵ� ���ڳ󵵸� ����
            % find_Ffunction: Em������ ���� ����� Fermi �Լ� ������ Energy ������ ã��
            % negf_Transport: NEGF�� �ؼ��Ͽ� ���ڳ󵵸� ��� (2���ϴ� ���� - valley degeneracy)
            % valley #1(l,t,t)
            [E_v1, FF1_v1, FF2_v1] = find_Ffunction(Em_t, k, totalE, FF1_t, FF2_t); 
            nn1 = nn1 + 2*negf_Transport(1, Em_t, Vm_t, k, E_v1, FF1_v1, FF2_v1);
            % valley #2(t,l,t)
            [E_v2, FF1_v2, FF2_v2] = find_Ffunction(Em_t, k, totalE, FF1_l, FF2_l);
            nn2 = nn2 + 2*negf_Transport(2, Em_t, Vm_t, k, E_v2, FF1_v2, FF2_v2);            
        end
        for k = 1:5     % mode ���� 5�� ���, �� mode �� ���Ͽ� ���Ǵ� ���ڳ󵵸� ���� 
            % valley #3(t,t,l)
            [E_v3, FF1_v3, FF2_v3] = find_Ffunction(Em_l, k, totalE, FF1_t, FF2_t);
            nn3 = nn3 + 2*negf_Transport(3, Em_l, Vm_l, k, E_v3, FF1_v3, FF2_v3);
        end
        nn = nn1 + nn2 + nn3;   % �� valley�� ���� ���ڳ󵵸� ���� 
        
        %% Poisson ������ �ؼ� 
        % �ִ� �ݺ� Ƚ��, jacobian ���, ���ټ�, ���ڳ�, Vgs��ȭ��(������ �ʱ� ������ Vg_bias)
        [ phi, nn ] = nLinPoisson2D( 100, jbase, phi, nn, Vgs_delta);

        %% ���ſ��� üũ�Ͽ� ����Ż�⿩�� ����  
        stop(i,j) = max(max(abs(phi - phi_old)));
        disp(sprintf('[%d]self-consist loop[%d]-error: %d \n', i, j, stop(i,j)));
        if (stop(i,j) < 5e-4) || (j == 100)
            break;
        end
    end 
    %% ������ Ż���ϸ� ������ ��� (�����ϱ� �� ����ϴ� ���� ���� ����)
    for k = 1:2     % mode ���� 2�� ���, �� mode �� ���Ͽ� ���Ǵ� �������� ����
        % valley #1(l,t,t)
        % negf_Current: NEGF�� �ؼ��Ͽ� �������� ��� (2���ϴ� ���� - valley degeneracy)
        [E_v1, FF1_v1, FF2_v1] = find_Ffunction(Em_t, k, totalE, FF1_t, FF2_t);
        Ids(i) = Ids(i) + 2*negf_Current(1, Em_t, k, E_v1, FF1_v1, FF2_v1);
        % valley #2(t,l,t)        
        [E_v2, FF1_v2, FF2_v2] = find_Ffunction(Em_t, k, totalE, FF1_l, FF2_l);
        Ids(i) = Ids(i) + 2*negf_Current(2, Em_t, k, E_v2, FF1_v2, FF2_);
    end
    for k = 1:5     % mode ���� 5�� ���, �� mode �� ���Ͽ� ���Ǵ� �������� ����
        % valley #3(t,t,l)
        [E_v3, FF1_v3, FF2_v3] = find_Ffunction(Em_l, k, totalE, FF1_t, FF2_t);
        Ids(i) = Ids(i) + 2*negf_Current(3, Em_l, k, E_v3, FF1_v3, FF2_v3);
    end
    
    %% ��� ���� 
    % ���ŵ� ����� �� bias point���� ����. 
    if (Vds(i) - floor(Vds(i)*10)/10 < 1e-10) %% 0 V, 0.1 V, 0.2 V, 0.3 V, 0.4 V, 0.5 V
        % 0.1�� ��� point ���� ���� ��� ������ ���� 
        % - ������ ���� �����ϹǷ� ��ġ ������ save�Լ��� ����� �ּ�ó���ϼ���
        % ���� ��� ���� : �� valley, mode �� spectral density A(x,E) (source/drain), 
        %                 transmission coefficient T(E), current Ids(E)
        % valley #1(l,t,t)
        [ v1_1_A1, v1_1_A2, v1_1_T, v1_1_Ids ] = negf_ShowVariables( 1, Em_t, 1, totalE, FF1_t, FF2_t );
        [ v1_2_A1, v1_2_A2, v1_2_T, v1_2_Ids ] = negf_ShowVariables( 1, Em_t, 2, totalE, FF1_t, FF2_t );
        % valley #2(t,l,t)
        [ v2_1_A1, v2_1_A2, v2_1_T, v2_1_Ids ] = negf_ShowVariables( 2, Em_t, 1, totalE, FF1_l, FF2_l );
        [ v2_2_A1, v2_2_A2, v2_2_T, v2_2_Ids ] = negf_ShowVariables( 2, Em_t, 2, totalE, FF1_l, FF2_l );
        % valley #3(t,t,l)
        [ v3_1_A1, v3_1_A2, v3_1_T, v3_1_Ids ] = negf_ShowVariables( 3, Em_l, 1, totalE, FF1_t, FF2_t );
        [ v3_2_A1, v3_2_A2, v3_2_T, v3_2_Ids ] = negf_ShowVariables( 3, Em_l, 2, totalE, FF1_t, FF2_t );
        [ v3_3_A1, v3_3_A2, v3_3_T, v3_3_Ids ] = negf_ShowVariables( 3, Em_l, 3, totalE, FF1_t, FF2_t );
        [ v3_4_A1, v3_4_A2, v3_4_T, v3_4_Ids ] = negf_ShowVariables( 3, Em_l, 4, totalE, FF1_t, FF2_t );
        [ v3_5_A1, v3_5_A2, v3_5_T, v3_5_Ids ] = negf_ShowVariables( 3, Em_l, 5, totalE, FF1_t, FF2_t );
        
        save(sprintf('result (Vg = 0.1V)\\result_%03d.mat',i)); % ����
        % ���� �� ���� ���� ������ ���� (�޸� ������ ���߱� ����)
        clear v1_1_A1 v1_1_A2 v1_1_T v1_1_Ids 
        clear v1_2_A1 v1_2_A2 v1_2_T v1_2_Ids
        clear v2_1_A1 v2_1_A2 v2_1_T v2_1_Ids
        clear v2_2_A1 v2_2_A2 v2_2_T v2_2_Ids
        clear v3_1_A1 v3_1_A2 v3_1_T v3_1_Ids
        clear v3_2_A1 v3_2_A2 v3_2_T v3_2_Ids
        clear v3_3_A1 v3_3_A2 v3_3_T v3_3_Ids
        clear v3_4_A1 v3_4_A2 v3_4_T v3_4_Ids
        clear v3_5_A1 v3_5_A2 v3_5_T v3_5_Ids
    else % ���ŵ� ����� ���� 
        save(sprintf('result (Vg = 0.1V)\\result_%03d.mat',i)); % ����
    end
end 

return;






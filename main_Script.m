%% Vds sweep �����ڵ� (ä�� ũ�Ⱑ �ٸ� ���� �ùķ��̼�)
% ���丮 Ȯ�� 
if exist('Drain', 'dir') == 0
    mkdir('Drain');
end
for i = 1:4
    if exist(sprintf('Drain\\%d',i), 'dir') == 0 
        mkdir(sprintf('Drain\\%d',i));
    end
    if exist(sprintf('Drain\\%d\\Vgs_0.0',i), 'dir') == 0 
        mkdir(sprintf('Drain\\%d\\Vgs_0.0',i));
    end
    if exist(sprintf('Drain\\%d\\Vgs_0.5',i), 'dir') == 0 
        mkdir(sprintf('Drain\\%d\\Vgs_0.5',i));
    end
end

movefile('xmesh_0.5.csv','xmesh_backup.csv');   % xmesh_0.5.csv �� xmesh_backup.csv�� ���� (���� ���� ���)
% xmesh_0.5.csv�� x���� ��� �������Ϸ� ��� 

movefile('xmesh_1.csv','xmesh_0.5.csv');	% xmesh_1.csv �� xmesh_0.5.csv�� ���� (�ε�)
main_fx_Vds_sweep(0, 1);    % Vgs = 0.0 V, Vds = 0.00, 0.01, ... , 0.50 V �ùķ��̼� ����
main_fx_Vds_sweep(0.5, 1);  % Vgs = 0.5 V, Vds = 0.00, 0.01, ... , 0.50 V �ùķ��̼� ����
movefile('xmesh_0.5.csv','xmesh_1.csv');    % xmesh_0.5.csv �� xmesh_1.csv�� ���� (����)

movefile('xmesh_2.csv','xmesh_0.5.csv');    % xmesh_2.csv �� xmesh_0.5.csv�� ���� (�ε�)
main_fx_Vds_sweep(0, 2);
main_fx_Vds_sweep(0.5, 2);
movefile('xmesh_0.5.csv','xmesh_2.csv');    % xmesh_0.5.csv �� xmesh_2.csv�� ���� (����)

movefile('xmesh_3.csv','xmesh_0.5.csv');    % xmesh_3.csv �� xmesh_0.5.csv�� ���� (�ε�)
main_fx_Vds_sweep(0, 3);
main_fx_Vds_sweep(0.5, 3);
movefile('xmesh_0.5.csv','xmesh_3.csv');    % xmesh_0.5.csv �� xmesh_3.csv�� ���� (����)

movefile('xmesh_4.csv','xmesh_0.5.csv');    % xmesh_4.csv �� xmesh_0.5.csv�� ���� (�ε�)
main_fx_Vds_sweep(0, 4);
main_fx_Vds_sweep(0.5, 4);
movefile('xmesh_0.5.csv','xmesh_4.csv');    % xmesh_0.5.csv �� xmesh_4.csv�� ���� (����)

movefile('xmesh_backup.csv','xmesh_0.5.csv');   % xmesh_0.5.csv �� xmesh_backup.csv�� ���� (���� ���� ����)

%% Vgs sweep �����ڵ�
% bias���¿��� �̸� ���� ����� �ʿ��� 
main_fx_Vgs_sweep(0.1);
main_fx_Vgs_sweep(0.2);
main_fx_Vgs_sweep(0.3);
main_fx_Vgs_sweep(0.4);
main_fx_Vgs_sweep(0.5);
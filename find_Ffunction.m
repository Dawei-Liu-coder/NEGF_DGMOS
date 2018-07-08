function [ E, FF1, FF2 ] = find_Ffunction( Em, k_count, totalE, FF1, FF2 )
%% �Լ����� : total ���������� ���ǵ� FF1, FF2 �� ��꿡 �ʿ��� ������ ã�Ƽ� ��ȯ
% �� �Ķ���ʹ� ������ �����ϴ�. 
% Em : subband minimum
% k_count : �ؼ��� mode ��ȣ 
% totalE : �ùķ��̼ǿ��� ����Ǵ� ��� ������ ������ 
% FF1 : Source�ܿ����� Fermi �Լ���, E index�� ����
% FF2 : Drain�ܿ����� Fermi �Լ���, E index�� ����

%% ��꿡 �ʿ��� ������ ã�Ƽ� ��ȯ 
deltaE = totalE(2) - totalE(1); % ������ ��� ���� 
Em = Em(:,k_count); % �־��� mode ��ȣ�� ���� subband minimum ����
E1 = min(Em)-0.15;  % subband minimum���� 0.15 eV ���� ���������� 
E2 = max(Em)+0.25;  % subband maximum���� 0.25 eV ���� ������������ ��� 
E1 = (round(E1/deltaE))*deltaE;     % ���� ù ������ ������ ��� ������ ����� ���� 
E2 = (round(E2/deltaE))*deltaE;     % ���� �� ������ ������ ��� ������ ����� ���� 
ind1 = find(abs(totalE - E1) < deltaE/5, 1, 'first');   % ���� ù ������ �ε����� �� ������ �������� ������
ind2 = find(abs(totalE - E2) < deltaE/5, 1, 'first');   % ���� �� ������ �ε����� �� ������ �������� ������

% �� ������ �ε����� �����Ͽ��� ��쿡 ���� ����ó�� 
i = isempty(ind1);
j = isempty(ind2);
if (i == 1) || (j == 1) % �� �߿� �ϳ��� ��������� ó�� ���� 
    disp('failure to find sub-energy array in total-energy region');    % ��꿡 ������ ������ �˸� 
    if (i == 1) % ���� ù ������ �� ã������ 
        ind1 = 1;   % ù ��° �ε����� �������� 
    end
    if (j == 1) % �� ������ ��ã������ 
        ind2 = size(totalE,2);  % ������ �ε����� �������� 
    end
end

% ù ������ �� ���������� �ε����� �̿�, �ʿ��� �κ��� ã�� 
% Fermi�Լ��� ���̰� �ϳ� ª�� ������ ��� �� ���������� ������̱� ����. 
% NEGF ó�� �� ������ ��忡 ���Ͽ� ���� ó���� �����ϹǷ� ��������. 
E = totalE(ind1:ind2);      % ������ ���� 
FF1 = FF1(ind1:ind2-1);     % Fermi �Լ�(source)
FF2 = FF2(ind1:ind2-1);     % Fermi �Լ�(drain)
end
function [ F ] = configue_Ffunction(valleyNum, nodeNum, Vds, E)
%% �Լ����� : homogeneous �������� ���е� Fermi �Լ��� ����մϴ�.
% �� �Ķ���ʹ� ������ �����ϴ�. 
% valleyNum : y���������� valley ��ȣ (#2: m_l, #1 & #3 : m_t)
% nodeNum : ������ ���� homogeneous ���� �������� �Ҵ��� ��� ���� (�������� ��Ȯ)
% Vds : bias�� ���� �߻��ϴ� Fermi �������� offset [V]
% E : �ؼ��� ����� longitudinal ������ [eV]

%% �۷ι� ����� �ҷ��ɴϴ�. 
if (3 < valleyNum ) || (valleyNum < 1)
    disp(sprintf('option : out of range!'));
    return;
end
global mass;    % valley�� ���� ���� ��ȿ ���� 
m_y = mass.m_y(valleyNum);

% NEGF���� ����� ���б������� ���� ������ ��带 �߰������� ��ȯ 
dE = E(2) - E(1);   
E_l = E(1:end-1) + dE/2; % ��ȯ�� longitudinal ������

% Ư�� ���� ������ longitudinal �������� ���Ͽ� homogeneous �������� ���е� Fermi �Լ��� ���
F = Fhalfinv( -Vds -E_l, nodeNum, m_y);

end


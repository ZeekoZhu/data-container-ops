#
# ģ�顰Docker-Ops����ģ���嵥
#
# ������: Zeeko
#
# ����ʱ��: 2018/6/12
#

@{

# ����嵥�����Ľű�ģ��������ģ���ļ���
RootModule = 'DataContainer-Utils.psm1'

# ��ģ��İ汾�š�
ModuleVersion = '0.1.0'

# ֧�ֵ� PSEditions
# CompatiblePSEditions = @()

# ����Ψһ��ʶ��ģ��� ID
GUID = '4e2868ab-e830-4b97-99df-8c77f3f4a137'

# ��ģ�������
Author = 'Zeeko'

# ��ģ�������Ĺ�˾��Ӧ��
CompanyName = 'δ֪'

# ��ģ��İ�Ȩ����
Copyright = '(c) 2018 Zeeko����������Ȩ����'

# ��ģ�����ṩ���ܵ�˵��
Description = 'Some utils for docker operations'

# ��ģ��Ҫ��� Windows PowerShell �������Ͱ汾
PowerShellVersion = '5.1'

# ��ģ��Ҫ��� Windows PowerShell ����������
# PowerShellHostName = ''

# ��ģ��Ҫ��� Windows PowerShell ��������Ͱ汾
# PowerShellHostVersion = ''

# ��ģ��Ҫ��ʹ�õ���� Microsoft .NET Framework �汾�����Ⱦ��������� PowerShell Desktop �汾��Ч��
# DotNetFrameworkVersion = ''

# ��ģ��Ҫ��ʹ�õ���͹�����������ʱ(CLR)�汾�����Ⱦ��������� PowerShell Desktop �汾��Ч��
# CLRVersion = ''

# ��ģ��Ҫ��Ĵ�������ϵ�ṹ(�ޡ�X86��Amd64)
# ProcessorArchitecture = ''

# �����ڵ����ģ��֮ǰ�ȵ���ȫ�ֻ����е�ģ��
# RequiredModules = @()

# �����ģ��֮ǰ������صĳ���
# RequiredAssemblies = @()

# �����ģ��֮ǰ�����ڵ��÷������еĽű��ļ�(.ps1)��
# ScriptsToProcess = @()

# �����ģ��ʱҪ���ص������ļ�(.ps1xml)
# TypesToProcess = @()

# �����ģ��ʱҪ���صĸ�ʽ�ļ�(.ps1xml)
# FormatsToProcess = @()

# ����Ϊ RootModule/ModuleToProcess ����ָ��ģ���Ƕ��ģ�鵼���ģ��
# NestedModules = @()

# Ҫ�Ӵ�ģ���е����ĺ�����Ϊ�˻��������ܣ��벻Ҫʹ��ͨ�������Ҫɾ������Ŀ�����û��Ҫ�����ĺ�������ʹ�ÿ����顣
FunctionsToExport = 'Restore-FromConfig', 'Backup-FromConfig', 'Get-DataContainerConfig'

# Ҫ�Ӵ�ģ���е����� cmdlet��Ϊ�˻��������ܣ��벻Ҫʹ��ͨ�������Ҫɾ������Ŀ�����û��Ҫ������ cmdlet����ʹ�ÿ����顣
CmdletsToExport = @()

# Ҫ�Ӵ�ģ���е����ı���
# VariablesToExport = @()

# Ҫ�Ӵ�ģ���е����ı�����Ϊ�˻��������ܣ��벻Ҫʹ��ͨ�������Ҫɾ������Ŀ�����û��Ҫ�����ı�������ʹ�ÿ����顣
AliasesToExport = @()

# Ҫ�Ӵ�ģ�鵼���� DSC ��Դ
# DscResourcesToExport = @()

# ���ģ��һ����������ģ����б�
# ModuleList = @()

# ���ģ��һ�����������ļ����б�
# FileList = @()

# Ҫ���ݵ� RootModule/ModuleToProcess ��ָ����ģ���ר�����ݡ��⻹���ܰ��� PSData ��ϣ���Լ� PowerShell ʹ�õ�����ģ��Ԫ���ݡ�
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = 'docker','docker-volumes','backup'

        # A URL to the license for this module.
        # LicenseUri = ''

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/ZeekoZhu/data-container-ops'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        # ReleaseNotes = ''

        # External dependent modules of this module
        # ExternalModuleDependencies = ''

    } # End of PSData hashtable
    
 } # End of PrivateData hashtable

# ��ģ��� HelpInfo URI
# HelpInfoURI = ''

# �Ӵ�ģ���е����������Ĭ��ǰ׺������ʹ�� Import-Module -Prefix ����Ĭ��ǰ׺��
# DefaultCommandPrefix = ''

}


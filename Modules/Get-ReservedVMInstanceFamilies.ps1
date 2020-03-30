function Get-ReservedVMInstanceFamilies
{

    <#

    .SYNOPSIS
    Create a PowerShell object based on the VM Size Flexibility information at https://docs.microsoft.com/azure/virtual-machines/windows/reserved-vm-instance-size-flexibility

    #>

    [CmdletBinding()]
    Param
    (
    )
    Begin
    {
        $url = "https://isfratio.blob.core.windows.net/isfratio/ISFRatio.csv"
        Invoke-WebRequest -Uri $url -OutFile ".\Modules\ISFRatio.csv"
        $InstanceSizeFlexibilityRatio = Import-Csv -Path ".\Modules\ISFRatio.csv"

        $ReservedVMInstances = [PSCustomObject]@()
        # B-Series
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_B1ls"; "ReservedInstanceFamily" = "B-Series"; "ReservedInstanceRatio" = "1" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_B1s"; "ReservedInstanceFamily" = "B-Series"; "ReservedInstanceRatio" = "2" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_B2s"; "ReservedInstanceFamily" = "B-Series"; "ReservedInstanceRatio" = "8" }
        # B-Series High Memory
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_B1ms"; "ReservedInstanceFamily" = "B-Series High Memory"; "ReservedInstanceRatio" = "1" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_B2ms"; "ReservedInstanceFamily" = "B-Series High Memory"; "ReservedInstanceRatio" = "4" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_B4ms"; "ReservedInstanceFamily" = "B-Series High Memory"; "ReservedInstanceRatio" = "8" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_B8ms"; "ReservedInstanceFamily" = "B-Series High Memory"; "ReservedInstanceRatio" = "16" }
        # D-Series
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_D1"; "ReservedInstanceFamily" = "D-Series"; "ReservedInstanceRatio" = "1" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_D2"; "ReservedInstanceFamily" = "D-Series"; "ReservedInstanceRatio" = "2" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_D3"; "ReservedInstanceFamily" = "D-Series"; "ReservedInstanceRatio" = "4" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_D4"; "ReservedInstanceFamily" = "D-Series"; "ReservedInstanceRatio" = "8" }
        # D-Series High Memory
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_D11"; "ReservedInstanceFamily" = "D-Series High Memory"; "ReservedInstanceRatio" = "1" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_D12"; "ReservedInstanceFamily" = "D-Series High Memory"; "ReservedInstanceRatio" = "2" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_D13"; "ReservedInstanceFamily" = "D-Series High Memory"; "ReservedInstanceRatio" = "4" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_D14"; "ReservedInstanceFamily" = "D-Series High Memory"; "ReservedInstanceRatio" = "8" }
        # DS-Series
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_DS1"; "ReservedInstanceFamily" = "DS-Series"; "ReservedInstanceRatio" = "1" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_DS2"; "ReservedInstanceFamily" = "DS-Series"; "ReservedInstanceRatio" = "2" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_DS3"; "ReservedInstanceFamily" = "DS-Series"; "ReservedInstanceRatio" = "4" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_DS4"; "ReservedInstanceFamily" = "DS-Series"; "ReservedInstanceRatio" = "8" }
        # DS-Series High Memory
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_DS11"; "ReservedInstanceFamily" = "DS-Series High Memory"; "ReservedInstanceRatio" = "1" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_DS12"; "ReservedInstanceFamily" = "DS-Series High Memory"; "ReservedInstanceRatio" = "2" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_DS13"; "ReservedInstanceFamily" = "DS-Series High Memory"; "ReservedInstanceRatio" = "4" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_DS14"; "ReservedInstanceFamily" = "DS-Series High Memory"; "ReservedInstanceRatio" = "8" }
        # DSv2-Series
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_DS1_v2"; "ReservedInstanceFamily" = "DSv2-Series"; "ReservedInstanceRatio" = "1" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_DS2_v2"; "ReservedInstanceFamily" = "DSv2-Series"; "ReservedInstanceRatio" = "2" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_DS3_v2"; "ReservedInstanceFamily" = "DSv2-Series"; "ReservedInstanceRatio" = "4" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_DS4_v2"; "ReservedInstanceFamily" = "DSv2-Series"; "ReservedInstanceRatio" = "8" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_DS5_v2"; "ReservedInstanceFamily" = "DSv2-Series"; "ReservedInstanceRatio" = "16" }
        # DSv2-Series High Memory
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_DS11_v2"; "ReservedInstanceFamily" = "DSv2-Series High Memory"; "ReservedInstanceRatio" = "1" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_DS11-1_v2"; "ReservedInstanceFamily" = "DSv2-Series High Memory"; "ReservedInstanceRatio" = "1" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_DS12_v2"; "ReservedInstanceFamily" = "DSv2-Series High Memory"; "ReservedInstanceRatio" = "2" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_DS12-1_v2"; "ReservedInstanceFamily" = "DSv2-Series High Memory"; "ReservedInstanceRatio" = "2" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_DS12-2_v2"; "ReservedInstanceFamily" = "DSv2-Series High Memory"; "ReservedInstanceRatio" = "2" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_DS13_v2"; "ReservedInstanceFamily" = "DSv2-Series High Memory"; "ReservedInstanceRatio" = "4" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_DS13-2_v2"; "ReservedInstanceFamily" = "DSv2-Series High Memory"; "ReservedInstanceRatio" = "4" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_DS13-4_v2"; "ReservedInstanceFamily" = "DSv2-Series High Memory"; "ReservedInstanceRatio" = "4" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_DS14_v2"; "ReservedInstanceFamily" = "DSv2-Series High Memory"; "ReservedInstanceRatio" = "8" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_DS14-4_v2"; "ReservedInstanceFamily" = "DSv2-Series High Memory"; "ReservedInstanceRatio" = "8" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_DS14-8_v2"; "ReservedInstanceFamily" = "DSv2-Series High Memory"; "ReservedInstanceRatio" = "8" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_DS15_v2"; "ReservedInstanceFamily" = "DSv2-Series High Memory"; "ReservedInstanceRatio" = "10" }
        # DSv3-Series
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_D2s_v3"; "ReservedInstanceFamily" = "DSv3-Series"; "ReservedInstanceRatio" = "1" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_D4s_v3"; "ReservedInstanceFamily" = "DSv3-Series"; "ReservedInstanceRatio" = "2" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_D8s_v3"; "ReservedInstanceFamily" = "DSv3-Series"; "ReservedInstanceRatio" = "4" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_D16s_v3"; "ReservedInstanceFamily" = "DSv3-Series"; "ReservedInstanceRatio" = "8" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_D32s_v3"; "ReservedInstanceFamily" = "DSv3-Series"; "ReservedInstanceRatio" = "16" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_D64s_v3"; "ReservedInstanceFamily" = "DSv3-Series"; "ReservedInstanceRatio" = "32" }
        # Dv2-Series
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_D1_v2"; "ReservedInstanceFamily" = "Dv2-Series"; "ReservedInstanceRatio" = "1" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_D2_v2"; "ReservedInstanceFamily" = "Dv2-Series"; "ReservedInstanceRatio" = "2" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_D3_v2"; "ReservedInstanceFamily" = "Dv2-Series"; "ReservedInstanceRatio" = "4" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_D4_v2"; "ReservedInstanceFamily" = "Dv2-Series"; "ReservedInstanceRatio" = "8" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_D5_v2"; "ReservedInstanceFamily" = "Dv2-Series"; "ReservedInstanceRatio" = "16" }
        # Dv2-Series High Memory
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_D11_v2"; "ReservedInstanceFamily" = "Dv2-Series High Memory"; "ReservedInstanceRatio" = "1" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_D12_v2"; "ReservedInstanceFamily" = "Dv2-Series High Memory"; "ReservedInstanceRatio" = "2" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_D13_v2"; "ReservedInstanceFamily" = "Dv2-Series High Memory"; "ReservedInstanceRatio" = "4" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_D14_v2"; "ReservedInstanceFamily" = "Dv2-Series High Memory"; "ReservedInstanceRatio" = "8" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_D15_v2"; "ReservedInstanceFamily" = "Dv2-Series High Memory"; "ReservedInstanceRatio" = "10" }
        # Dv3-Series
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_D2_v3"; "ReservedInstanceFamily" = "Dv3-Series"; "ReservedInstanceRatio" = "1" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_D4_v3"; "ReservedInstanceFamily" = "Dv3-Series"; "ReservedInstanceRatio" = "2" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_D8_v3"; "ReservedInstanceFamily" = "Dv3-Series"; "ReservedInstanceRatio" = "4" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_D16_v3"; "ReservedInstanceFamily" = "Dv3-Series"; "ReservedInstanceRatio" = "8" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_D32_v3"; "ReservedInstanceFamily" = "Dv3-Series"; "ReservedInstanceRatio" = "16" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_D64_v3"; "ReservedInstanceFamily" = "Dv3-Series"; "ReservedInstanceRatio" = "32" }
        # ESv3-Series
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_E2s_v3"; "ReservedInstanceFamily" = "ESv3-Series"; "ReservedInstanceRatio" = "1" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_E4s_v3"; "ReservedInstanceFamily" = "ESv3-Series"; "ReservedInstanceRatio" = "2" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_E4s-2s_v3"; "ReservedInstanceFamily" = "ESv3-Series"; "ReservedInstanceRatio" = "2" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_E8s_v3"; "ReservedInstanceFamily" = "ESv3-Series"; "ReservedInstanceRatio" = "4" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_E8-2s_v3"; "ReservedInstanceFamily" = "ESv3-Series"; "ReservedInstanceRatio" = "4" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_E8-4s_v3"; "ReservedInstanceFamily" = "ESv3-Series"; "ReservedInstanceRatio" = "4" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_E16s_v3"; "ReservedInstanceFamily" = "ESv3-Series"; "ReservedInstanceRatio" = "8" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_E16-4s_v3"; "ReservedInstanceFamily" = "ESv3-Series"; "ReservedInstanceRatio" = "8" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_E16-8s_v3"; "ReservedInstanceFamily" = "ESv3-Series"; "ReservedInstanceRatio" = "8" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_E20s_v3"; "ReservedInstanceFamily" = "ESv3-Series"; "ReservedInstanceRatio" = "10" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_E32s_v3"; "ReservedInstanceFamily" = "ESv3-Series"; "ReservedInstanceRatio" = "16" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_E32-8s_v3"; "ReservedInstanceFamily" = "ESv3-Series"; "ReservedInstanceRatio" = "16" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_E32-16s_v3"; "ReservedInstanceFamily" = "ESv3-Series"; "ReservedInstanceRatio" = "16" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_E64s_v3"; "ReservedInstanceFamily" = "ESv3-Series"; "ReservedInstanceRatio" = "28.8" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_E64-16s_v3"; "ReservedInstanceFamily" = "ESv3-Series"; "ReservedInstanceRatio" = "28.8" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_E64-32s_v3"; "ReservedInstanceFamily" = "ESv3-Series"; "ReservedInstanceRatio" = "28.8" }
        # Ev3-Series
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_E2_v3"; "ReservedInstanceFamily" = "Ev3-Series"; "ReservedInstanceRatio" = "1" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_E4_v3"; "ReservedInstanceFamily" = "Ev3-Series"; "ReservedInstanceRatio" = "2" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_E8_v3"; "ReservedInstanceFamily" = "Ev3-Series"; "ReservedInstanceRatio" = "4" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_E16_v3"; "ReservedInstanceFamily" = "Ev3-Series"; "ReservedInstanceRatio" = "8" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_E20_v3"; "ReservedInstanceFamily" = "Ev3-Series"; "ReservedInstanceRatio" = "10" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_E32_v3"; "ReservedInstanceFamily" = "Ev3-Series"; "ReservedInstanceRatio" = "16" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_E64_v3"; "ReservedInstanceFamily" = "Ev3-Series"; "ReservedInstanceRatio" = "32" }
        # F-Series
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_F1"; "ReservedInstanceFamily" = "F-Series"; "ReservedInstanceRatio" = "1" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_F2"; "ReservedInstanceFamily" = "F-Series"; "ReservedInstanceRatio" = "2" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_F4"; "ReservedInstanceFamily" = "F-Series"; "ReservedInstanceRatio" = "4" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_F8"; "ReservedInstanceFamily" = "F-Series"; "ReservedInstanceRatio" = "8" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_F16"; "ReservedInstanceFamily" = "F-Series"; "ReservedInstanceRatio" = "16" }
        # FS-Series
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_F1s"; "ReservedInstanceFamily" = "FS-Series"; "ReservedInstanceRatio" = "1" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_F2s"; "ReservedInstanceFamily" = "FS-Series"; "ReservedInstanceRatio" = "2" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_F4s"; "ReservedInstanceFamily" = "FS-Series"; "ReservedInstanceRatio" = "4" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_F8s"; "ReservedInstanceFamily" = "FS-Series"; "ReservedInstanceRatio" = "8" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_F16s"; "ReservedInstanceFamily" = "FS-Series"; "ReservedInstanceRatio" = "16" }
        # FSv2-Series
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_F2s_v2"; "ReservedInstanceFamily" = "FSv2-Series"; "ReservedInstanceRatio" = "1" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_F4s_v2"; "ReservedInstanceFamily" = "FSv2-Series"; "ReservedInstanceRatio" = "2" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_F8s_v2"; "ReservedInstanceFamily" = "FSv2-Series"; "ReservedInstanceRatio" = "4" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_F16s_v2"; "ReservedInstanceFamily" = "FSv2-Series"; "ReservedInstanceRatio" = "8" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_F32s_v2"; "ReservedInstanceFamily" = "FSv2-Series"; "ReservedInstanceRatio" = "16" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_F64s_v2"; "ReservedInstanceFamily" = "FSv2-Series"; "ReservedInstanceRatio" = "32" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_F72s_v2"; "ReservedInstanceFamily" = "FSv2-Series"; "ReservedInstanceRatio" = "36" }
        # H-Series
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_H8"; "ReservedInstanceFamily" = "H-Series"; "ReservedInstanceRatio" = "1" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_H16"; "ReservedInstanceFamily" = "H-Series"; "ReservedInstanceRatio" = "2" }
        # H-Series High Memory
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_H8m"; "ReservedInstanceFamily" = "H-Series High Memory"; "ReservedInstanceRatio" = "1" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_H16m"; "ReservedInstanceFamily" = "H-Series High Memory"; "ReservedInstanceRatio" = "2" }
        # LS-Series
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_L4s"; "ReservedInstanceFamily" = "LS-Series"; "ReservedInstanceRatio" = "1" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_L8s"; "ReservedInstanceFamily" = "LS-Series"; "ReservedInstanceRatio" = "2" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_L16s"; "ReservedInstanceFamily" = "LS-Series"; "ReservedInstanceRatio" = "4" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_L32s"; "ReservedInstanceFamily" = "LS-Series"; "ReservedInstanceRatio" = "8" }
        # M-Series
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_M64s"; "ReservedInstanceFamily" = "M-Series"; "ReservedInstanceRatio" = "1" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_M128s"; "ReservedInstanceFamily" = "M-Series"; "ReservedInstanceRatio" = "2" }
        # M-Series Fractional
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_M16s"; "ReservedInstanceFamily" = "M-Series Fractional"; "ReservedInstanceRatio" = "1" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_M32s"; "ReservedInstanceFamily" = "M-Series Fractional"; "ReservedInstanceRatio" = "2" }
        # M-Series Fractional High Memory
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_M8ms"; "ReservedInstanceFamily" = "M-Series Fractional High Memory"; "ReservedInstanceRatio" = "1" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_M8-2ms"; "ReservedInstanceFamily" = "M-Series Fractional High Memory"; "ReservedInstanceRatio" = "1" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_M8-4ms"; "ReservedInstanceFamily" = "M-Series Fractional High Memory"; "ReservedInstanceRatio" = "1" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_M16ms"; "ReservedInstanceFamily" = "M-Series Fractional High Memory"; "ReservedInstanceRatio" = "2" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_M16-4ms"; "ReservedInstanceFamily" = "M-Series Fractional High Memory"; "ReservedInstanceRatio" = "2" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_M16-8ms"; "ReservedInstanceFamily" = "M-Series Fractional High Memory"; "ReservedInstanceRatio" = "2" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_M32ms"; "ReservedInstanceFamily" = "M-Series Fractional High Memory"; "ReservedInstanceRatio" = "4" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_M32-8ms"; "ReservedInstanceFamily" = "M-Series Fractional High Memory"; "ReservedInstanceRatio" = "4" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_M32-8ms"; "ReservedInstanceFamily" = "M-Series Fractional High Memory"; "ReservedInstanceRatio" = "4" }
        # M-Series Fractional Large
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_M32ls"; "ReservedInstanceFamily" = "M-Series Fractional Large"; "ReservedInstanceRatio" = "1" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_M64ls"; "ReservedInstanceFamily" = "M-Series Fractional Large"; "ReservedInstanceRatio" = "2" }
        # M-Series High Memory
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_M64ms"; "ReservedInstanceFamily" = "M-Series High Memory"; "ReservedInstanceRatio" = "1" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_M64-16ms"; "ReservedInstanceFamily" = "M-Series High Memory"; "ReservedInstanceRatio" = "1" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_M64-32ms"; "ReservedInstanceFamily" = "M-Series High Memory"; "ReservedInstanceRatio" = "1" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_M128ms"; "ReservedInstanceFamily" = "M-Series High Memory"; "ReservedInstanceRatio" = "2" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_M128-32ms"; "ReservedInstanceFamily" = "M-Series High Memory"; "ReservedInstanceRatio" = "2" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_M128-64ms"; "ReservedInstanceFamily" = "M-Series High Memory"; "ReservedInstanceRatio" = "2" }
        # NC-Series
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_NC6"; "ReservedInstanceFamily" = "NC-Series"; "ReservedInstanceRatio" = "1" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_NC12"; "ReservedInstanceFamily" = "NC-Series"; "ReservedInstanceRatio" = "2" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_NC24"; "ReservedInstanceFamily" = "NC-Series"; "ReservedInstanceRatio" = "4" }
        # NCv2-Series
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_NC6s_v2"; "ReservedInstanceFamily" = "NCv2-Series"; "ReservedInstanceRatio" = "1" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_NC12s_v2"; "ReservedInstanceFamily" = "NCv2-Series"; "ReservedInstanceRatio" = "2" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_NC24s_v2"; "ReservedInstanceFamily" = "NCv2-Series"; "ReservedInstanceRatio" = "4" }
        # NCv3-Series
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_NC6s_v3"; "ReservedInstanceFamily" = "NCv3-Series"; "ReservedInstanceRatio" = "1" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_NC12s_v3"; "ReservedInstanceFamily" = "NCv3-Series"; "ReservedInstanceRatio" = "2" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_NC24s_v3"; "ReservedInstanceFamily" = "NCv3-Series"; "ReservedInstanceRatio" = "4" }
        # ND-Series
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_ND6s"; "ReservedInstanceFamily" = "ND-Series"; "ReservedInstanceRatio" = "1" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_ND12s"; "ReservedInstanceFamily" = "ND-Series"; "ReservedInstanceRatio" = "2" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_ND24s"; "ReservedInstanceFamily" = "ND-Series"; "ReservedInstanceRatio" = "4" }
        # NV-Series
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_NV6"; "ReservedInstanceFamily" = "NV-Series"; "ReservedInstanceRatio" = "1" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_NV12"; "ReservedInstanceFamily" = "NV-Series"; "ReservedInstanceRatio" = "2" }
        $ReservedVMInstances += [PSCustomObject]@{"VMSize" = "Standard_NV24"; "ReservedInstanceFamily" = "NV-Series"; "ReservedInstanceRatio" = "4" }
    }
    Process
    {
        #Write-Output -InputObject $ReservedVMInstances
        Write-Output -InputObject $InstanceSizeFlexibilityRatio
    }
    End
    {
    }
}

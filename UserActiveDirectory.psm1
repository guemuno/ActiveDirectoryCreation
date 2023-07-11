class UserActiveDirectory {
    [string]$LastName
    [string]$Name
    [string]$JobTitle
    [string]$Department
    [string]$UserName
    [datetime]$DateofBirth
    UserActiveDirectory(
        [string]$LastName,
        [string]$Name,
        [string]$JobTitle,
        [string]$Department,
        [datetime]$DateofBirth){
        $this.LastName = $LastName
        $this.Name = $Name
        $this.JobTitle = $JobTitle
        $this.Department = $Department
        $this.DateofBirth = $DateofBirth
        $this.UserName = $Name.Replace(" ","") + "." + $LastName.Replace(" ","")
    }
}
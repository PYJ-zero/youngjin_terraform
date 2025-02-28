### 리전별 리소스 관리를 위해 모듈 생성 ###
####################################

module "ap_northeast_2" {
    source = "./ap_northeast_2"
    project_name = var.project_name
}
### 리전별 리소스 관리를 위해 모듈 생성 ###
####################################

module "ap_northeast_1" {
    source = "./ap_northeast_1"
    project_name = var.project_name
    region_code = var.region_code
}
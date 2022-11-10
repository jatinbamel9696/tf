module "iam" {
  source = "./iam"
  rotation_lambda_arn = module.lambda.lambda_arn
  pb = module.pb.pb_arn
  tags = var.tags
}

module "lambda" {
  source = "./lambda"
  tags = var.tags
 
}

module "pb" {
  source = "./pb"
  tags = var.tags
}


















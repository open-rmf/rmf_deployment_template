from copy import deepcopy

from api_server.default_config import config as default_config


config = deepcopy(default_config)
config["host"] = "0.0.0.0"
config["port"] = 8000
config["db_url"] = "postgres://rmf-web-rmf-server:rmf-web-rmf-server@rmf-web-rmf-server-db/rmf-web-rmf-server"
config["public_url"] = "https://rmf-deployment-template.open-rmf.org/rmf/api/v1"
config["log_level"] = "INFO"
config["builtin_admin"] = "admin"
config["jwt_public_key"] = "/jwt-configmap/jwt-pub-key.pub"
config["oidc_url"] = "https://rmf-deployment-template.open-rmf.org/auth/realms/rmf-web/.well-known/openid-configuration"
config["aud"] = "dashboard"
config["iss"] = "https://rmf-deployment-template.open-rmf.org/auth/realms/rmf-web"

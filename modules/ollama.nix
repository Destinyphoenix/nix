{ ... }:
{
  services.ollama = {
    enable = true;
    loadModels = [ "qwen2.5-coder:1.5b-base" ];
    #qwen2.5-coder:3b-base
  };
}

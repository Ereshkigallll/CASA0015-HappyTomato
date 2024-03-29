import torch
from torch.utils.mobile_optimizer import optimize_for_mobile

# 首先加载TorchScript模型
model = torch.jit.load('./model_traced.pt')

# 然后使用optimize_for_mobile优化模型
optimized_model = optimize_for_mobile(model)

# 保存优化后的模型为.ptl格式，适用于移动设备
optimized_model._save_for_lite_interpreter("model_optimized.ptl")

import torch
from torchvision.models import shufflenet_v2_x1_0, ShuffleNet_V2_X1_0_Weights

# 初始化ShuffleNetV2模型，不使用预训练权重
model = shufflenet_v2_x1_0(weights=None)

# 调整最后的全连接层以匹配你的分类任务（这里是二分类任务）
num_ftrs = model.fc.in_features
model.fc = torch.nn.Linear(num_ftrs, 2)  # 将输出特征数更改为2

# 现在模型的fc层与保存的权重兼容，可以安全地加载权重
model.load_state_dict(torch.load('./model_epoch_20.pth'))
model.eval()

# 使用一个示例输入跟踪模型
example_input = torch.rand(1, 3, 48, 48)  # 假设输入是3通道48x48的图像
traced_model = torch.jit.trace(model, example_input)

# 保存TorchScript模型
traced_model.save("model_traced.pt")

import torch
import torch.nn as nn
from torchvision.models import shufflenet_v2_x1_0, ShuffleNet_V2_X1_0_Weights
from torch.utils.mobile_optimizer import optimize_for_mobile

class MyShuffleNet(nn.Module):
    def __init__(self):
        super(MyShuffleNet, self).__init__()
        self.shufflenet = shufflenet_v2_x1_0(weights=ShuffleNet_V2_X1_0_Weights.IMAGENET1K_V1)
        num_ftrs = self.shufflenet.fc.in_features
        self.shufflenet.fc = nn.Linear(num_ftrs, 3)  # 修改为3类输出

    def forward(self, x):
        x = self.shufflenet(x)
        return x

# 初始化MyShuffleNet模型
my_model = MyShuffleNet()

# 确保模型处于评估模式
my_model.eval()

# 加载你的模型权重
state_dict = torch.load('./model_epoch_25.pth')
my_model.load_state_dict(state_dict)

# 使用一个示例输入跟踪模型
example_input = torch.rand(1, 3, 48, 48)  # 假设输入是3通道48x48的图像
traced_model = torch.jit.trace(my_model, example_input)
opti_model = optimize_for_mobile(traced_model)

# 保存TorchScript模型
opti_model._save_for_lite_interpreter("model_best.pt")

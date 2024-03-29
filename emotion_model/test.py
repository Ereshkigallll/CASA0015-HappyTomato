import torch
import torch.nn as nn
from torchvision import datasets, transforms, models
from torch.utils.data import DataLoader
import os
from torchvision.models import shufflenet_v2_x1_0

if __name__ == '__main__':
    # 测试集数据变换
    data_transforms = {
        'test': transforms.Compose([
            transforms.Resize((48, 48)),
            transforms.ToTensor(),
            transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
        ]),
    }

    # 加载测试集
    data_dir = './MMAFEDB/'
    batch_size = 1  # 设置batch_size为1以单独处理每张图片
    test_dataset = datasets.ImageFolder(os.path.join(data_dir, 'test'), data_transforms['test'])
    test_loader = DataLoader(test_dataset, batch_size=batch_size, shuffle=False, num_workers=4)

    # 加载模型
    model = shufflenet_v2_x1_0(weights=None)
    num_ftrs = model.fc.in_features
    model.fc = nn.Linear(num_ftrs, 2)
    model_path = './model_epoch_21.pth'
    model.load_state_dict(torch.load(model_path))

    device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
    model = model.to(device)
    model.eval()

    # 测试模型
    running_corrects = 0
    for inputs, labels in test_loader:
        inputs = inputs.to(device)
        labels = labels.to(device)

        with torch.no_grad():
            outputs = model(inputs)
            _, preds = torch.max(outputs, 1)

        # 打印模型输出和预测
        print(f"Model output: {outputs}")
        print(f"Predicted label: {preds.item()}, True label: {labels.item()}")

        running_corrects += torch.sum(preds == labels.data)

    test_acc = running_corrects.double() / len(test_dataset)
    print(f'Test Acc: {test_acc:.4f}')

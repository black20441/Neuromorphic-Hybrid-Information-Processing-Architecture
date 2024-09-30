## Prerequisites  
* Create a conda virtual environment by running  
```
conda create -n SNNCom python=3.8
```  
* To install required librarys,just running  
```
pip install -r requirements.txt
```  
## Structure of this repository  
```
│SNNCom/
├──cifar10/
│  ├── SNNCom_ANN.ipynb
│  ├── SNNCom_ANN+SNN.ipynb
│  ├── SNNCom_SNN.ipynb
│  ├── utils.py
├──ecg/
│  ├── SNNCom_ANN_ecg.ipynb
│  ├── SNNCom_ANN+SNN_ecg.ipynb
│  ├── SNNCom_SNN_ecg.ipynb
│  ├── utils.py
├──MNIST/
│  ├── SNNCom_ANN_MNIST.ipynb
│  ├── SNNCom_ANN+SNN_MNIST.ipynb
│  ├── SNNCom_SNN_MNIST.ipynb
│  ├── utils.py
├──spenchcommands/
│  ├── SNNCom_ANN_spenchcommands.ipynb
│  ├── SNNCom_ANN+SNN_spenchcommands.ipynb
│  ├── SNNCom_SNN_spenchcommands.ipynb
│  ├── utils.py
├──requirements.txt
├──README.md
├──LICENSE
```
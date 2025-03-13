import cactas as C
from sklearn.model_selection import KFold
from keras import backend as K
from sklearn.model_selection import KFold, train_test_split
import numpy as np
import sys

DATAPATH='/raid/mpsych/CACTAS/DATA/'
CAPATHS = {
    'CA_ESUS3': '/raid/mpsych/CACTAS/DATA/CA_ESUS3',
    'CA_CEA5': '/raid/mpsych/CACTAS/DATA/CA_CEA5',
    'CA_CAS5': '/raid/mpsych/CACTAS/DATA/CA_CAS5'
}

images, labels = C.Helper.load_datas(DATAPATH)
masks = C.Helper.load_seg_datas(DATAPATH)

num_patients = len(images)

images, labels, masks = C.LOO.orders(images, labels, masks)
images, labels, masks, slices_per_patient = C.LOO.data_normalization(DATAPATH, CAPATHS, images, labels, masks)
X_train, y_train, m_train = C.LOO.extract_slices(images, labels, masks)
X_train_array = C.LOO.mask_image(X_train, m_train)

kf = KFold(n_splits=num_patients // 22)

cumulative_slices = np.cumsum([0] + slices_per_patient)


train_indices_str = sys.argv[1]
train_index = list(map(int, train_indices_str.split()))
test_indices_str = sys.argv[2]
test_index = list(map(int, test_indices_str.split()))



X_train_array, y_train_array, X_val_array, y_val_array, X_test_array, y_test_array = C.LOO.split_set(train_index, test_index, X_train_array, y_train, cumulative_slices)
    
K.clear_session()

model = C.Helper.create_unet(X_train_array[0].shape)
history = model.fit(X_train_array, y_train_array, 
                    epochs=200, 
                    batch_size=16, 
                    validation_data=(X_val_array, y_val_array))


y_pred = model.predict(X_test_array)
#print("pass1")
loss, iou, iou_thresholded = model.evaluate(X_test_array, y_test_array, verbose=0)
#print("pass2")

print("loss: " + str(loss))
print("iou: " + str(iou)) 
print("iou_thresholded: " + str(iou_thresholded))


a = y_pred
a_binary = np.zeros(a.shape, dtype=np.bool_)
a_binary[a > 0.5] = True
    
loss_t, iou_t, iou_thresholded_t = model.evaluate(X_test_array, a_binary, verbose=0)
#print("pass3")

print("Thresholded loss: " + str(loss_t))
print("Thresholded IoU: " + str(iou_t)) 
print("Thresholded IoU_thresholded: " + str(iou_thresholded_t))
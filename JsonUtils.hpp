#ifndef JSONUTILS_HPP
#define JSONUTILS_HPP
#pragma once

#include <QObject>
#include <QTextStream>
#include <QFileDialog>
#include <QJsonDocument>
#include <QtDebug>

class JsonUtils : public QObject {
    Q_OBJECT

public:

    explicit JsonUtils(QObject* parent = nullptr) { Q_UNUSED(parent) };

    Q_INVOKABLE void saveJson(QString json){
        QString fileName = QFileDialog::getSaveFileName(nullptr, tr("Save File"), QDir::homePath(), tr("Json (*.json)"));
        if(fileName.isEmpty() || fileName.isNull()) return;

        QFile file(fileName);
        if(file.open(QFile::WriteOnly | QFile::Text)){
            // converting to json document only to get the indented text
            auto jsonDoc = QJsonDocument::fromJson(json.toUtf8());
            file.write(jsonDoc.toJson());
        }
        file.close();
    };

    Q_INVOKABLE QString getFileContent(QUrl url){
        QFile file(url.toLocalFile());
        if(!file.open(QFile::ReadOnly | QFile::Text))
            qDebug() << "Open file url error";
        QTextStream in(&file);
        return in.readAll();
    }

};

#endif
